{
  description = "Fluxer desktop application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      fluxer = pkgs.stdenv.mkDerivation rec {
        pname = "fluxer";
        version = "0.0.8";

        src = pkgs.fetchurl {
          url = "https://api.fluxer.app/dl/desktop/stable/linux/x64/latest/tar_gz";
          sha256 = "0b8gc31lc91wv5xgrwkbxi7xprr4nc8w01jvv3z201w1ls7kkxmc";
        };

        nativeBuildInputs = [
          pkgs.autoPatchelfHook
          pkgs.makeWrapper
          pkgs.copyDesktopItems
        ];

        desktopItems = [
          (pkgs.makeDesktopItem {
            name = "fluxer";
            desktopName = "Fluxer";
            exec = "fluxer";
            comment = "Fluxer desktop application";
            categories = [ "Network" "AudioVideo" ];
          })
        ];

        buildInputs = [
          pkgs.alsa-lib
          pkgs.at-spi2-atk
          pkgs.at-spi2-core
          pkgs.atk
          pkgs.cairo
          pkgs.cups
          pkgs.dbus
          pkgs.expat
          pkgs.gdk-pixbuf
          pkgs.glib
          pkgs.gtk3
          pkgs.libdrm
          pkgs.libxkbcommon
          pkgs.mesa
          pkgs.nspr
          pkgs.nss
          pkgs.pango
          pkgs.libx11
          pkgs.libxcomposite
          pkgs.libxdamage
          pkgs.libxext
          pkgs.libxfixes
          pkgs.libxrandr
          pkgs.libxcb
          pkgs.libxtst
          pkgs.libxt
        ];

        runtimeDependencies = [
          pkgs.libGL
          pkgs.vulkan-loader
        ];

        unpackPhase = ''
          tar -xzf $src
        '';

        installPhase = ''
          runHook preInstall

          mkdir -p $out/opt/fluxer
          cp -r fluxer-stable-${version}-x64/* $out/opt/fluxer/

          mkdir -p $out/bin
          makeWrapper $out/opt/fluxer/fluxer $out/bin/fluxer \
            --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath runtimeDependencies}"

          runHook postInstall
        '';

        meta = with pkgs.lib; {
          description = "Fluxer desktop application";
          homepage = "https://fluxer.app";
          platforms = [ "x86_64-linux" ];
          mainProgram = "fluxer";
        };
      };
    in
    {
      packages.${system} = {
        default = fluxer;
        fluxer = fluxer;
      };
    };
}
