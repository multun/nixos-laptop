{ lib, stdenv }:

stdenv.mkDerivation {
  name = "ergodox-ez-udev";

  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    install -Dm 644 ${./70-ergodox-ez.rules} $out/lib/udev/rules.d/70-ergodox-ez.rules
  '';

  meta = with lib; {
    homepage = "http://wireless.kernel.org/en/users/Documentation/rfkill";
    description = "Rules+hook for udev to catch rfkill state changes";
    maintainers = [ maintainers.multun ];
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
