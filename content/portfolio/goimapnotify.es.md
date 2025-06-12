---
title: 'Goimapnotify'
slug: goimapnotify
description: ejecuta scripts en tu máquina ante eventos IMAP
project_description: Ejecuta scripts cuando hay cambios en un buzón IMAP (mensajes nuevos/eliminados/actualizados) usando IDLE
started: 2017
stopped: ""
relationship: autor
cover: "/images/portfolio/goimapnotify/cover.jpg"
images: ["/images/portfolio/goimapnotify/cover.jpg"]
topics: [Golang]
programming_langs: [Golang]
tech: [IMAP, IMAP IDLE]
draft: false
git: https://gitlab.com/shackra/goimapnotify/
weight: 100
---

Comencé `goimapnotify` en 2017 porque en ese momento (y actualmente) hacía la mayor parte de mi gestión de correo electrónico dentro de GNU Emacs, mi editor de texto preferido. Lo que hace `goimapnotify` es conectarse con tu servidor de correo a través del protocolo IMAP, observar cuándo llega un nuevo correo o se elimina uno, y ejecutar un *script* para que tu computadora haga algo cuando ocurre un evento en tu buzón.

Cuando inicié mi proyecto, las soluciones existentes no manejaban bien las conexiones a Internet inestables, ¡así que podía pasar horas sin saber que alguien me había enviado un correo! Ahí es donde `goimapnotify` sobresale. En la Wiki de Arch Linux, en la [entrada para Isync](https://web.archive.org/web/20250514051418/https://wiki.archlinux.org/title/Isync#With_imapnotify), se puede leer lo siguiente:

> **IMAP IDLE** es una forma de recibir **notificaciones push** para descargar nuevos correos electrónicos, en lugar de hacer consultas periódicas al servidor. Esto tiene la ventaja de ahorrar ancho de banda y entregar el correo tan pronto como esté disponible. Isync no tiene soporte nativo para IDLE, pero podemos usar un programa como imapnotify para llamar a mbsync cuando recibas un nuevo correo. **Para este ejemplo usaremos el paquete goimapnotify, del cual se reporta que funciona mejor con interrupciones frecuentes de red.**

Este proyecto se menciona en comentarios y publicaciones de blogs de otras personas:
- [Un comentario en Hacker News](https://news.ycombinator.com/item?id=42367084)
- [Otro comentario en Hacker News sobre el flujo de trabajo del usuario](https://news.ycombinator.com/item?id=30934275)
- [Correo electrónico en la terminal: una guía completa al estilo Unix del correo](https://bence.ferdinandy.com/2023/07/20/email-in-the-terminal-a-complete-guide-to-the-unix-way-of-email/#automation)
- [Configuración de Doom Emacs](https://pratikvn.github.io/my-emacs-config/#fetching)

## Este proyecto está disponible en los siguientes repositorios de GNU/Linux

[![Packaging status](https://repology.org/badge/vertical-allrepos/goimapnotify.svg)](https://repology.org/project/goimapnotify/versions)
