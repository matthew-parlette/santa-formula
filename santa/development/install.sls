# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "santa/development/map.jinja" import santa with context %}

santa-development-image:
  dockerng.image_present:
    - name: {{ santa.image }}:{{ santa.branch }}
    - force: True
