{% set buildtitle = "Your server is ready!" %}
{% set buildsubtitle = "Get in there and make something." %}
{% set titlecolor = "hsl(130,70%,70%)" %}
finishlogappend:
  file.append:
    - name: /var/log/salt/buildlog.html
    - text: </pre><p class="lead">All done! Enjoy your new server.</p></div></div></div></body></html>
