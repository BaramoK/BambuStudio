{
  description = "Bambu Studio packaged from the official Linux AppImage";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      pname = "bambu-studio";
      version = "2.9.1";

      appimage = pkgs.fetchurl {
        url = "https://github.com/bambulab/BambuStudio/releases/download/v02.09.01.70/BambuStudio_ubu22_v02.09.01.70-20261103183404.AppImage";
        hash = "sha256-4N+22v4Bgba/hjW7uaexBvAvI0P45BlJ8dFWs/NiQeU=";
      };

      appimageContents = pkgs.appimageTools.extract {
        inherit pname version;
        src = appimage;
      };

      bambu-studio = pkgs.appimageTools.wrapType2 {
        inherit pname version;
        src = appimage;
        contents = appimageContents;
        executableName = "bambu-studio";

        extraInstallCommands = ''
          install -Dm644 ${./resources/images/BambuStudio_192px.png} \
            $out/share/icons/hicolor/192x192/apps/bambu-studio.png

          mkdir -p $out/share/applications
          cat > $out/share/applications/bambu-studio.desktop <<'EOF'
          [Desktop Entry]
          Name=Bambu Studio
          GenericName=3D Printing Software
          Comment=Prepare, slice, and print 3D models with Bambu Studio
          Exec=bambu-studio %U
          Icon=bambu-studio
          Terminal=false
          Type=Application
          Categories=Graphics;3DGraphics;Engineering;
          MimeType=model/stl;model/3mf;application/vnd.ms-3mfdocument;application/prs.wavefront-obj;application/x-amf;x-scheme-handler/bambustudio;x-scheme-handler/bambustudioopen;
          StartupNotify=false
          EOF
        '';

        meta = {
          description = "Bambu Lab's 3D printing slicer, using the official Ubuntu 22.04 AppImage";
          homepage = "https://github.com/bambulab/BambuStudio";
          platforms = [ system ];
        };
      };
    in
    {
      packages.${system} = {
        default = bambu-studio;
        inherit bambu-studio;
      };

      apps.${system}.default = {
        type = "app";
        program = "${bambu-studio}/bin/bambu-studio";
        meta = bambu-studio.meta;
      };
    };
}
