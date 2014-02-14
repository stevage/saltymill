prereqs:
  pkg.installed:
    - names: [ unzip, wget ]
    - require_in: cartogothic

# Bah, the old source (fontsquirrel) doesn't have this font anymore. Not sure if this .otf version will work.
/usr/share/fonts/truetype/cartogothic_std.zip:
  file.managed:
    - source: http://www.freefontspro.com/d/12524/cartogothic_std.zip
  cmd.wait:
    - cwd: /usr/share/fonts/truetype
    - name: |
        unzip -d CartoGothic -o *.zip
    - watch [ file: /usr/share/fonts/truetype/cartogothic_std.zip ]

