# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "santa/development/map.jinja" import santa with context %}

include:
  - santa.development.install

santa-development-database:
  file.touch:
    - name: {{ santa.database }}
    - makedirs: True

santa-development-public:
  file.directory:
    - name: {{ santa.public }}
    - makedirs: True

santa-development-container:
  dockerng.running:
    - name: {{ santa.name }}
    - image: {{ santa.image }}:{{ santa.branch }}
    {%- if santa.has_key('database') %}
    - binds:
      - {{ santa.database }}:/usr/src/app/db/development.sqlite3:rw
      - {{ santa.public }}:/usr/src/app/public:rw
    {%- endif %}
    - port_bindings:
      - {{ santa.port }}:3000
    {%- if santa.environment %}
    - environment:
      {%- for env, value in santa.environment.items() %}
      - {{ env }}: {{ value|yaml_squote }}
      {%- endfor %}
    {%- endif %}
    - require:
      - dockerng: santa-development-image
      - file: santa-development-database
      - file: santa-development-public

{%- if santa.mattermost %}
santa-development-result:
  module.run:
    - name: mattermost.post_message
    - api_url: {{ santa.mattermost["api_url"] }}
    - hook: {{ santa.mattermost["hook"] }}
    - channel: {{ santa.mattermost["channel"] }}
    - username: {{ salt['grains.get']('id', 'saltstack') }}
    - message: New development Santa container has been deployed
    - onchanges:
      - dockerng: santa-development-container
{%- endif %}
