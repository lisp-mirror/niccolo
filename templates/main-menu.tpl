<div class="left-menu">
  <a href="<!-- TMPL_VAR path-prefix -->/">
    <!-- TMPL_IF has-nyan -->
        <img class="nyan-logo" src="<!-- TMPL_VAR path-prefix -->/images/chem-nyan/chem-nyan.gif">
    <!-- TMPL_ELSE -->
        <img id="software-logo" src="<!-- TMPL_VAR path-prefix -->/images/lab-logo.svg">
    <!-- /TMPL_IF -->
  </a>
  <!-- TMPL_IF has-nyan -->
    <p class="nyan-caption">Let's chem-nyan!</p>
  <!-- /TMPL_IF -->

  <ul id="accordion-menu">
    <li class="menu-level-1"><!-- TMPL_VAR safety-lbl --></li>
    <li class="menu-level-2">
      <ul>
	<li>
	  <a href="<!-- TMPL_VAR manage-ghs-hazard -->">
	    <!-- TMPL_VAR manage-ghs-hazard-lbl -->
	  </a>
	</li>
	<li class="menu-level-2">
	  <a href="<!-- TMPL_VAR manage-ghs-precaution -->">
	    <!-- TMPL_VAR manage-ghs-precaution-lbl -->
	  </a>
	</li>
	<li class="menu-level-2">
	  <a href="<!-- TMPL_VAR manage-cer -->">
	    <!-- TMPL_VAR manage-cer-lbl -->
	  </a>
	</li>
	<li class="menu-level-2">
	  <a href="<!-- TMPL_VAR manage-sensors -->">
	    <!-- TMPL_VAR  manage-sensors-lbl -->
	  </a>
	</li>
	<li class="menu-level-2">
	  <a href="<!-- TMPL_VAR manage-adr -->">
	    <!-- TMPL_VAR manage-adr-lbl -->
	  </a>
	</li>
	<li class="menu-level-2">
	  <a href="<!-- TMPL_VAR waste-letter -->">
	    <!-- TMPL_VAR waste-letter-lbl -->
	  </a>
	</li>
	<li class="menu-level-2">
	  <a href="<!-- TMPL_VAR waste-stats -->">
	    <!-- TMPL_VAR waste-stats-lbl -->
	  </a>
	</li>

	<li>
	  <a href="<!-- TMPL_VAR l-factor-calculator -->">
	    <!-- TMPL_VAR l-factor-calculator-lbl -->
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR l-factor-calculator-carc -->">
	    <!-- TMPL_VAR l-factor-calculator-carc-lbl -->
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR store-classify-tree -->">
	    <!-- TMPL_VAR store-classify-tree-lbl -->
	  </a>
	</li>

      </ul>
    </li>
    <li class="menu-level-1"><!-- TMPL_VAR places-lbl --></li>
    <li class="menu-level-2">
      <ul>
	<li>
	  <a href="<!-- TMPL_VAR manage-address -->">
	    <!-- TMPL_VAR manage-address-lbl -->
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR manage-building -->">
	    <!-- TMPL_VAR manage-building-lbl -->
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR manage-maps -->">
	    <!-- TMPL_VAR manage-maps-lbl -->
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR manage-storage -->">
	    <!-- TMPL_VAR manage-storage-lbl -->
	  </a>
	</li>
      </ul>
    </li>
    <li class="menu-level-1"><!-- TMPL_VAR chemical-compounds-lbl --></li>
    <li class="menu-level-2">
      <ul>
	<li>
	  <a href="<!-- TMPL_VAR manage-chemicals -->">
	    <!-- TMPL_VAR manage-chemicals-lbl -->
	  </a>
	</li>
      </ul>
    </li>
    <li class="menu-level-1"><!-- TMPL_VAR chemical-products-lbl --></li>
    <li class="menu-level-2">
      <ul>
	<li>
	  <a href="<!-- TMPL_VAR manage-chemical-products -->">
	    <!-- TMPL_VAR manage-chemical-products-lbl -->
	  </a>
	</li>
      </ul>
    </li>

    <li class="menu-level-1"><!-- TMPL_VAR users-lbl --></li>
    <li class="menu-level-2">
      <ul>
	<li>
	  <a href="<!-- TMPL_VAR user-messages -->">
	    <!-- TMPL_VAR user-messages-lb -->
	  </a>
	</li>

	<li>
	  <a href="<!-- TMPL_VAR broadcast-messages -->">
	    <!-- TMPL_VAR broadcast-messages-lb -->
	  </a>
	</li>

	<li>
	  <a href="<!-- TMPL_VAR manage-user -->">
	    <!-- TMPL_VAR manage-user-lbl -->
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR change-password -->">
	    <!-- TMPL_VAR change-password-lbl -->
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR user-preferences -->">
	    <!-- TMPL_VAR user-preferences-lbl -->
	  </a>
	</li>

      </ul>
    </li>

  </ul>
</div>
