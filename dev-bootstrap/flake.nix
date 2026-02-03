{
  description = "Bootstrap dev tools (editors, VCS, env managers, CLIs)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];

      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system:
          f (import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          })
        );
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.buildEnv {
          name = "dev-bootstrap";

          paths = with pkgs; [
            # editors / UI entry points
            emacs-nox
            tmux

            # VCS & core CLI
            git
            htop
            jq
            ripgrep

            # environment / toolchain bootstrap
            direnv
            nix-direnv
            rustup
            uv

            # AI / external CLIs
            claude-code
            gemini-cli
          ];
        };
      });

      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            clang
            cmake
            lld
            pkg-config
          ];

          CC  = "clang";
          CXX = "clang++";

          shellHook = ''
            export RUSTFLAGS="-C linker=clang"
          '';
        };
      });
    };
}
