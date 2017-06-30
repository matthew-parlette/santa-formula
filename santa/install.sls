# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "santa/map.jinja" import santa with context %}

santa-image:
  dockerng.image_present:
    - name: {{ santa.image }}:{{ santa.branch }}
    - force: True
