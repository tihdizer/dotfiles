{ ... }:
{
  flake.modules.homeManager.tihdizer-mime =
    { ... }:
    let
      mimeMap = {
        "onlyoffice-desktopeditors.desktop" = [
          "application/msword"
          "application/vnd.ms-word"
          "application/x-msword"
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
          "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
          "application/vnd.oasis.opendocument.text"
          "application/vnd.oasis.opendocument.text-template"
          "application/rtf"
          "text/rtf"
          "application/vnd.ms-excel"
          "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
          "application/vnd.openxmlformats-officedocument.spreadsheetml.template"
          "application/vnd.oasis.opendocument.spreadsheet"
          "application/vnd.oasis.opendocument.spreadsheet-template"
          "application/vnd.ms-powerpoint"
          "application/vnd.openxmlformats-officedocument.presentationml.presentation"
          "application/vnd.openxmlformats-officedocument.presentationml.template"
          "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
          "application/vnd.oasis.opendocument.presentation"
          "application/vnd.oasis.opendocument.presentation-template"
        ];

        "readest.desktop" = [
          "application/pdf"
          "application/x-pdf"
          "application/epub+zip"
        ];

        "imv.desktop" = [
          "image/jpeg"
          "image/png"
          "image/gif"
          "image/webp"
          "image/svg+xml"
          "image/bmp"
          "image/avif"
          "image/tiff"
          "image/heic"
          "image/heif"
          "image/x-icon"
        ];

        "mpv.desktop" = [
          "audio/mpeg"
          "audio/mp3"
          "audio/flac"
          "audio/wav"
          "audio/x-wav"
          "audio/ogg"
          "audio/x-vorbis+ogg"
          "audio/x-flac"
          "audio/aac"
          "audio/m4a"
          "audio/mp4"
          "audio/opus"

          "video/mp4"
          "video/mkv"
          "video/x-matroska"
          "video/webm"
          "video/quicktime"
          "video/x-msvideo"
          "video/x-flv"
          "video/mpeg"
          "video/ogg"
        ];

        "google-chrome.desktop" = [
          "text/html"
          "application/xhtml+xml"
          "x-scheme-handler/http"
          "x-scheme-handler/https"
          "x-scheme-handler/about"
          "x-scheme-handler/unknown"
        ];

        "nvim.desktop" = [
          "text/plain"
          "text/markdown"
          "text/x-nix"
          "application/x-nix"
          "text/x-c"
          "text/x-c++"
          "text/x-python"
          "text/x-rust"
          "text/x-shellscript"
          "application/json"
          "application/x-yaml"
          "application/yaml"
          "application/toml"
          "application/xml"
          "text/xml"
        ];

        "yazi.desktop" = [
          "inode/directory"
        ];
      };

      defaultApps = builtins.foldl' (
        acc: desktop:
        let
          mimes = mimeMap.${desktop};
          entries = builtins.listToAttrs (
            map (mime: {
              name = mime;
              value = [ desktop ];
            }) mimes
          );
        in
        acc // entries
      ) { } (builtins.attrNames mimeMap);
    in
    {
      xdg.mimeApps = {
        enable = true;
        defaultApplications = defaultApps;
      };
    };
}
