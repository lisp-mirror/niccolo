"<!-- TMPL_VAR legend-group-lb -->"
<!-- TMPL_IF cer-group -->
"<!-- TMPL_VAR cer-group-caption-lb -->"
"<!-- TMPL_VAR code-lb -->","<!-- TMPL_VAR weight-lb -->"
<!-- TMPL_LOOP cer-group -->"<!-- TMPL_VAR cer-code -->","<!-- TMPL_VAR sum-weight -->"
<!-- /TMPL_LOOP -->

"<!-- TMPL_VAR buildings-group-caption-lb -->"
"<!-- TMPL_VAR building-description-lb -->","<!-- TMPL_VAR weight-lb -->"
<!-- TMPL_LOOP buildings-group -->"<!-- TMPL_VAR building-name -->,<!-- TMPL_VAR address-line-1 -->,<!-- TMPL_VAR city -->,<!-- TMPL_VAR zipcode -->","<!-- TMPL_VAR sum-weight -->"
<!-- /TMPL_LOOP -->

"<!-- TMPL_VAR user-group-caption-lb -->"
"<!-- TMPL_VAR username-lb -->","<!-- TMPL_VAR weight-lb -->"
"<!-- TMPL_LOOP user-group -->"<!-- TMPL_VAR username -->","<!-- TMPL_VAR sum-weight -->"
<!-- /TMPL_LOOP -->
<!-- /TMPL_IF -->

<!-- TMPL_UNLESS cer-group -->
<!-- TMPL_VAR not-found-lb -->
<!-- /TMPL_UNLESS -->
