<!-- TMPL_IF messages -->

<script>
 $(function () {
     $( ".add-registry-number-div").click(function (e){
         $(this).children("form").show(500);
     })
 });
</script>
<h3> <!-- TMPL_VAR waste-messages-hd-lb --></h3>

<!-- TMPL_LOOP messages -->
<table class="waste-messages">
    <thead>
        <tr>
            <th class="id-hd">ID</th>
            <th class="sent-time-hd"><!-- TMPL_VAR sent-time-lb --></th>
            <th class="sender-name-hd"><!-- TMPL_VAR sender-lb --></th>
            <th class="rcpt-name-hd"><!-- TMPL_VAR rcpt-lb --></th>
            <th class="subject-hd"><!-- TMPL_VAR subject-lb --></th>
            <th class="message-hd"><!-- TMPL_VAR message-lb --></th>
            <th class="registration-num-lb"><!-- TMPL_VAR registration-number-lb --></th>
            <th class="operations-lb"><!-- TMPL_VAR operations-lb --></th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td class="sender-name"><!-- TMPL_VAR msg-id --></td>
            <td class="sent-time"><!-- TMPL_VAR decoded-sent-time --></td>
            <td class="sender-name"><!-- TMPL_VAR sender-username --></td>
            <td class="rcpt-name"><!-- TMPL_VAR rcpt-username --></td>
            <td class="subject"><!-- TMPL_VAR subject --></td>
            <td class="message"><!-- TMPL_VAR text --></td>
            <td class="reg-number"><!-- TMPL_VAR registration-number --></td>
            <td class="operations">
                <a href="<!-- TMPL_VAR delete-link -->">
                    <!-- TMPL_INCLUDE 'delete-button.tpl' -->
                </a>
                <!-- TMPL_IF admin-p -->
                <a href="<!-- TMPL_VAR close-w-success-link -->"
                   onclick="return <!-- TMPL_INCLUDE 'confirm.tpl' -->">
                    <div class="close-w-success-button">
                        &nbsp;
                    </div>
                </a>
                <a href="<!-- TMPL_VAR close-w-failure-link -->"
                   onclick="return <!-- TMPL_INCLUDE 'confirm.tpl' -->">
                    <div class="close-w-failure-button">
                        &nbsp;
                    </div>
                </a>
                <div class="add-registry-number-div">
                    <a>
                        <div class="waste-assoc-registry-button">
                            <i class="fa fa-file-text fa-2x" aria-hidden="true">
                            </i>
                        </div>
                    </a>
                    <form style="display: none" method="GET"
                          action="<!-- TMPL_VAR assoc-reg-number-link -->">
                        <input type="hidden" name="<!-- TMPL_VAR name-id-message -->"
                               value="<!-- TMPL_VAR waste-id -->" />
                        <input type="text"   name="<!-- TMPL_VAR name-registration-num -->" />
                        <input type="submit"
                               onclick="return <!-- TMPL_INCLUDE 'confirm.tpl' -->">
                    </form>
                </div>
                <!-- /TMPL_IF -->
            </td>
        </tr>
        <!-- TMPL_LOOP children -->
        <tr>
            <td class="user-message-reply-row" colspan="8">
                <span class="fa fa-reply fa-rotate-180" aria-hidden="true"></span>
                <a class="open-response-link" href=" <!-- TMPL_VAR url -->">
                    <!-- TMPL_VAR time --> <!-- TMPL_VAR subject -->
                </a>
            </td>
        </tr>
        <!-- /TMPL_LOOP  -->
    </tbody>
</table>
<!-- /TMPL_LOOP  -->

<!-- /TMPL_IF -->
