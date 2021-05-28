{ rev    ? "c74fa74867a3cce6ab8371dfc03289d9cc72a66e"
, sha256 ? "13bnmpdmh1h6pb7pfzw5w3hm6nzkg9s1kcrwgw1gmdlhivrmnx75"
, pkgs   ? import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
    inherit sha256; }) {
    config.allowUnfree = true;
    config.allowBroken = false;
  }
}:

rec {

keysmith = pkgs.stdenv.mkDerivation rec {
  name = "keysmith-${version}";
  version = "0.0.0-unknown";

  src = pkgs.fetchFromGitHub {
    owner = "dfinity";
    repo = "keysmith";
    rev = "73bcfe2f1f5e8588be9104ed728b9d481296f3b2";
    sha256 = "1df488jyxnkgwp56jqwfrkys42xj9xsw7bic53flmdn7jd841abr";
    # date = 2021-05-26T02:30:38-07:00;
  };

  buildInputs = with pkgs; [ gnumake go git ];

  buildPhase = ''
    export HOME=$PWD
    go build
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv keysmith $out/bin
  '';
};

dfx = pkgs.stdenv.mkDerivation rec {
  name = "dfx-${version}";
  version = "0.7.0";

  src = pkgs.fetchurl {
    url = "https://sdk.dfinity.org/install.sh";
    sha256 = "1jzr1w5054r188qrjh3ra3gglfdkqwc8m03jdwraf1z4l3hvyflp";
    # date = 2021-05-26T14:45:23-0700;
  };

  buildInputs = with pkgs; [ curl cacert ];

  phases = [ "fixupPhase" "installPhase" ];

  installPhase = ''
    export DFX_INSTALL_ROOT=$out/bin
    mkdir -p $DFX_INSTALL_ROOT
    sed -i 's/if ! confirm_license; then/if false; then/' ${src}
    export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    export HOME=$PWD
    DFX_VERSION=${version} bash ${src}
  '';
};

shell = pkgs.mkShell {
  buildInputs = [ keysmith dfx ];
};

}
