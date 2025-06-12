---
title: 'Este sitio web 😎'
description: mi sitio web profesional, potenciado por Hugo y Nix
project_description: Un sitio web profesional estático generado con Hugo y desplegado con Nix
started: 2025
stopped: ""
relationship: autor
cover: "/images/portfolio/this-site/jorgearayadev.es.png"
images: [/images/portfolio/this-site/jorgearayadev.es.png]
topics: [sitio estático, Digital Ocean, Nginx, Let's Encrypt, GNU/Linux, NixOS]
programming_langs: [Nix]
tech: [Hugo, HTML, SCSS, NixOS]
draft: false
git: https://github.com/shackra/jorgeayara.dev/
weight: 110
---

Inicie este sitio web por varios motivos. El primero, para tener un espacio profesional en la web con contenido que sea útil para otros ingenieros de software y para demostrar a potenciales clientes mi experiencia en el campo. Segundo, como un ejercicio de "reproducibilidad".

Con "reproducibilidad" me refiero a la capacidad que tiene este sitio web de ser desplegado en cualquier otro lugar y el resultado sea exacto *bit por bit* al despliegue original. **Y no me refiero solo al contenido, sino a toda la pila de tecnología.**

A pesar de mi amplia experiencia con GNU/Linux, no soy un *sysadmin* y no disfruto mucho realizar ese tipo de tareas por lo que me decantado por NixOS como sistema operativo para el Droplet de Digital Ocean. NixOS no es una distribución cualquiera de GNU/Linux como Arch o Debian, es una distribución cuya configuración se expresa de forma declarativa y permite la "reproducibilidad" a la que aludí antes. Por ejemplo, esta fue la forma en la que configuré Nginx, Let's Encrypt y la carpeta donde va el contenido estático:

```nix
{
  config,
  ...
}:
{
  # ...código omitido por motivos de brevedad...
  systemd.tmpfiles.rules = [
    "d /var/www/jorgearaya.dev 0755 nginx nginx -"
  ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "jorge+dns@esavara.cr";
    certs."jorgearaya.dev" = {
      dnsProvider = "digitalocean";
      environmentFile = config.sops.templates."acme.conf".path;
      webroot = null;
    };
  };

  services.nginx = {
    enable = true;
    commonHttpConfig = ''
      map $http_accept_language $preferred_lang {
        default en;
        ~^es es;
        ~^en en;
      }
    '';

    virtualHosts."jorgearaya.dev" = {
      enableACME = true;
      forceSSL = true;
      root = "/var/www/jorgearaya.dev";

      extraConfig = ''
        charset utf-8;
        error_page 404 = @localized_404;
      '';

      locations."/" = {
        tryFiles = "$uri $uri/ =404";
        extraConfig = ''
          if ($request_uri = "/") {
            return 302 /$preferred_lang/;
          }
        '';
      };

      # dynamic 404
      locations."@localized_404" = {
        extraConfig = ''
          if ($uri ~* "^/([a-z]{2})/") {
            set $lang $1;
          }

          if ($lang = "") {
            set $lang $preferred_lang;
          }

          rewrite ^ /$lang/404.html break;
        '';
      };
    };
  };
}
```

Let's Encrypt y Nginx son expuestos en NixOS como módulos en `security.acme` y `services.nginx` respectivamente. Algunas propiedades de la configuración de estos servicios son ofrecidos por los módulos como un set de atributos, algunos atributos como `services.nginx.virtualHosts.<sitio>.extraConfig` sirve para definir configuración adicional que no es ofrecida en el set de atributos del modulo.

Con la configuración del Droplet declarada es cuestión de utilizar `nix run github:serokell/deploy-rs .#` para realizar su despliegue en una nueva generación. Si algo ha salido mal durante el despliegue (por ejemplo, un error en la configuración de Nginx que hace fallar la inicialización del servicio de systemd) el NixOS del Droplet simplemente retornará a la generación anterior y seguirá funcionando como si nada.

Para guardar la llave API del servicio Digital Ocean para el "DNS Challenge" de Let's Encrypt utilizo `sops-nix`, un modulo de NixOS que utiliza `sops` para el aprovisionamiento de secretos. El secreto para el "DNS Challenge" esta cifrado y registrado en el repositorio junto con la configuración del servidor, solamente las llaves publicas `age` registradas en la configuración de `sops` pueden descifrar el secreto y hacer uso de él. ¡Todo viene en un mismo envase por lo que es muy practico!

Si quiero mantener mi sistema actualizado a la ultima versión estable del repositorio de software de NixOS todo lo que debo hacer es refrescar las entradas (inputs) con `nix flake update` y desplegar la misma configuración con `deploy-rs`. Tener que utilizar solo 2 comandos es muy conveniente para el mantenimiento del servidor.

En el blog espero escribir más sobre Nix y NixOS, para que varios de los términos que utilicé en la descripción del proyecto tengan más sentido para el amigo lector.
