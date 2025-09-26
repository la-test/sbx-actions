{
  inputs = {
    # The nixpkgs channels we want to consume
    nixpkgs-25_05.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Some links to the above channels for consistent naming in outputs
    nixpkgs.follows = "nixpkgs-25_05";

    # Extra inputs for modules leaving outside nixpkgs
    flake-compat = {
      url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, ... }@attrs:
    let
      # The devShells of this flake only support one system = "x86_64-linux"
      # FIXME: could it support more (flake-utils does not help!)?
      system = "x86_64-linux";
      # The following devShell needs OpenToFu from NixOS >=25.05
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells."${system}".default = pkgs.mkShell {
        packages = [
          pkgs.gnupg
          pkgs.sops
        ];
        shellHook = ''
          # Print the version of some of the software used by this shell
          echo -n "gpg: v"&& ${pkgs.gnupg}/bin/gpg --version | head -1 | grep -Po '\d+\.\d+\.\d+'
          echo -n "sops: " && ${pkgs.sops}/bin/sops --version | head -1 | grep -Po '\d+\.\d+\.\d+'
          # Select the default password store to use
          export PASSWORD_STORE_DIR="secrets"
          # Inspect the current GnuPG config and save some data for later
          SOCKETAGENT_CUR="$(gpgconf --list-dirs agent-socket)"
          # Use a temporary key store for this shell to not alter the user's one
          export GNUPGHOME="$(mktemp --directory --tmpdir=$TMPDIR gnupg_home.XXXXXXXXXX)"
          # Prepare a minimal configuration, and avoid to fire a new agent
          umask 077 \
          && echo "no-autostart" >> "$GNUPGHOME/gpg.conf"
          SOCKETAGENT_TMP="$(gpgconf --list-dirs agent-socket)"
          # Re-use the current agent sockets for this temporary session
          ln -s "$SOCKETAGENT_CUR" "$SOCKETAGENT_TMP"
          # Import the relevant public-keys used by SOPS into the temporary GnuPG key store
          while read KEY_NAME KEY_ID; do
            gpg --quiet --import "$PASSWORD_STORE_DIR/.public-keys/$KEY_NAME.asc" \
            || echo "WARNING: Could not import $PASSWORD_STORE_DIR/.public-keys/$KEY_NAME.asc"
            gpg --quiet --import-ownertrust <(echo "$(\
              gpg --quiet --with-colons --fingerprint $KEY_ID | grep fpr | head -1 | cut -d ':' -f 10\
            ):6:") > /dev/null 2>&1
          done < <(grep -vP '(^\s*#)' .sops.yaml | grep -Po '(?<=\&)[^\s]+ [0-9a-fA-F]{40}')
        '';
      };
    };
}
