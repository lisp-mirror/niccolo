<!-- TMPL_INCLUDE 'messages-notification.js.tpl' -->

<div class="left-menu">
    <a href="<!-- TMPL_VAR path-prefix -->/">
        <!-- TMPL_IF has-nyan -->
        <img class="nyan-logo" src="<!-- TMPL_VAR path-prefix -->/images/chem-nyan/chem-nyan.gif">
        <!-- TMPL_ELSE -->
        <!-- TMPL_IF use-animated-logo-p -->
        <img id="software-logo"
             src="<!-- TMPL_VAR path-prefix -->/images/lab-logo.svg">
        <!-- TMPL_ELSE -->
        <img id="software-logo-noanim"
             src="<!-- TMPL_VAR path-prefix -->/images/lab-logo.svg">
        <!-- /TMPL_IF -->
        <!-- /TMPL_IF -->
    </a>
    <!-- TMPL_IF has-nyan -->
    <p class="nyan-caption">Let's chem-nyan!</p>
    <!-- /TMPL_IF -->

    <a id="message-notification-link"
       href="<!-- TMPL_VAR user-messages -->"
       onclick="forceHideMessageNotification()">
        <div id="message-notification-icon" class="fa fa-stack fa-3x">
            <i class="fa fa-envelope fa-stack-3x"></i>
            <i id="message-notification-count" class="fa fa-stack-1x"></i>
        </div>
    </a>
    <ul id="accordion-menu">
        <li class="menu-level-1"><!-- TMPL_VAR chemical-products-lbl --></li>
        <li class="menu-level-2">
            <ul>
                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR manage-chemical-products -->">
                        <!-- TMPL_VAR manage-chemical-products-lbl -->
                    </a>
                </li>
            </ul>
            <ul>
                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR import-chemical-products -->">
                        <!-- TMPL_VAR import-chemical-products-lbl -->
                    </a>
                </li>
            </ul>
        </li>
        <li class="menu-level-1"><!-- TMPL_VAR samples-lbl --></li>
        <li class="menu-level-2">
            <ul>
                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR manage-samples -->">
                        <!-- TMPL_VAR manage-samples-lbl -->
                    </a>
                </li>
            </ul>
        </li>
        <li class="menu-level-1"><!-- TMPL_VAR users-lbl --></li>
        <li class="menu-level-2">
            <ul>
                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR user-messages -->">
                        <!-- TMPL_VAR user-messages-lb -->
                    </a>
                </li>

                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR broadcast-messages -->">
                        <!-- TMPL_VAR broadcast-messages-lb -->
                    </a>
                </li>

                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR manage-user -->">
                        <!-- TMPL_VAR manage-user-lbl -->
                    </a>
                </li>

                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR manage-user-lab -->">
                        <!-- TMPL_VAR manage-user-lab-lbl -->
                    </a>
                </li>

                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR change-password -->">
                        <!-- TMPL_VAR change-password-lbl -->
                    </a>
                </li>

                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR user-preferences -->">
                        <!-- TMPL_VAR user-preferences-lbl -->
                    </a>
                </li>
            </ul>
        </li>
        <li class="menu-level-1"><!-- TMPL_VAR places-lbl --></li>
        <li class="menu-level-2">
            <ul>
                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR manage-address -->">
                        <!-- TMPL_VAR manage-address-lbl -->
                    </a>
                </li>
                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR manage-building -->">
                        <!-- TMPL_VAR manage-building-lbl -->
                    </a>
                </li>
                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR manage-laboratories -->">
                        <!-- TMPL_VAR manage-laboratories-lbl -->
                    </a>
                </li>

                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR manage-maps -->">
                        <!-- TMPL_VAR manage-maps-lbl -->
                    </a>
                </li>
                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR manage-storage -->">
                        <!-- TMPL_VAR manage-storage-lbl -->
                    </a>
                </li>
            </ul>
        </li>
        <li class="menu-level-1"><!-- TMPL_VAR chemical-compounds-lbl --></li>
        <li class="menu-level-2">
            <ul>
                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR manage-chemicals -->">
                        <!-- TMPL_VAR manage-chemicals-lbl -->
                    </a>
                </li>
            </ul>
        </li>
        <li class="menu-level-1"><!-- TMPL_VAR persons-lbl --></li>
        <li class="menu-level-2">
            <ul>
                <li class="with-menu-item-anim">
                    <a href="<!-- TMPL_VAR manage-person -->">
                        <!-- TMPL_VAR manage-person-lbl -->
                    </a>
                </li>
            </ul>
        </li>
    </ul>
</div>
