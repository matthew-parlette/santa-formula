# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "santa/map.jinja" import santa with context %}

include:
  - santa.install

santa-database:
  file.touch:
    - name: {{ santa.database }}

santa-public:
  file.directory:
    - name: {{ santa.public }}

santa-container:
  dockerng.running:
    - name: {{ santa.name }}
    - image: {{ santa.image }}:{{ santa.branch }}
    - binds:
      - {{ santa.database }}:/usr/src/app/db/production.sqlite3:rw
      - {{ santa.public }}:/usr/src/app/public:rw
    - port_bindings:
      - {{ santa.port }}:3000
    {%- if santa.environment %}
    - environment:
      {%- for env, value in santa.environment.items() %}
      - {{ env }}: {{ value|yaml_squote }}
      {%- endfor %}
    {%- endif %}
    - require:
      - dockerng: santa-image

{%- if santa.mattermost %}
santa-result:
  module.run:
    - name: mattermost.post_message
    - api_url: {{ santa.mattermost["api_url"] }}
    - hook: {{ santa.mattermost["hook"] }}
    - channel: {{ santa.mattermost["channel"] }}
    - username: {{ salt['grains.get']('id', 'saltstack') }}
    - message: New Santa container has been deployed
    - onchanges:
      - dockerng: santa-container
{%- endif %}
