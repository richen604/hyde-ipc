{
  description = "A development environment for hyde-ipc";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
    }:
    let
      system = "x86_64-linux"; # Assuming x86_64-linux, adjust if needed
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };
      rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          rustToolchain
          pkgs.pkg-config
          pkgs.openssl
          pkgs.libiconv # For macOS compatibility, though system is linux
        ];

        # Set environment variables for Rust
        RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
      };

      packages.${system}.default = pkgs.rustPlatform.buildRustPackage {
        pname = "hyde-ipc";
        version = "0.1.6";

        src = ./.; # Source is the current directory

        cargoLock = {
          lockFile = ./Cargo.lock;
        };

        # Build the 'cli' package within the workspace
        cargoBuildFlags = [
          "--package"
          "hyde-ipc"
        ];

        # Install the resulting binary
        installTargets = [ "hyde-ipc" ];

        buildInputs = [
          pkgs.pkg-config
          pkgs.openssl
          pkgs.libiconv
        ];

        nativeBuildInputs = [
          rustToolchain
        ];
      };
    };
}
