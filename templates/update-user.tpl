<script src="<!-- TMPL_VAR path-prefix -->/js/sort-table.js"></script>

<form method="GET" action="<!-- TMPL_VAR path-prefix -->/edit-user/<!-- TMPL_VAR id -->">
    <input type="text" id="update-user-id" value="<!-- TMPL_VAR id -->"
	   disabled="true"/>

    <label for="login-name"><!-- TMPL_VAR name-lb --></label>
    <input id="login-name" type="text" name="<!-- TMPL_VAR login-name -->"
           value="<!-- TMPL_VAR login-value -->">

    <label for="login-email"><!-- TMPL_VAR email-lb --></label>
    <input id="login-email" type="text" name="<!-- TMPL_VAR login-email -->"
           value="<!-- TMPL_VAR email-value -->">

    <label for="levels-select"><!-- TMPL_VAR levels-options-lb --></label>
    <select id="levels-select" name="<!-- TMPL_VAR levels-select -->">
        <option value="-1"></option>
        <!-- TMPL_LOOP level-options -->
        <option value="<!-- TMPL_VAR level -->"><!-- TMPL_VAR expl --></option>
        <!-- /TMPL_LOOP  -->
    </select>

    <input id="login-submit" type="submit">

</form>

<!-- TMPL_INCLUDE 'back-button.tpl' -->
