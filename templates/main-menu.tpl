<div class="logout-link">
  <span class="logout-username">
    <!-- TMPL_VAR session-username -->
  </span>
  <!-- TMPL_IF logout-link -->
  <a href="<!-- TMPL_VAR logout-link -->">
    <button class="button-logout">Logout</button>
  </a>
  <!-- /TMPL_IF -->
  <!-- TMPL_IF login-link -->
  <a href="<!-- TMPL_VAR login-link -->">
    <button class="button-login">Login</button>
  </a>
  <!-- /TMPL_IF -->
</div>

<div class="left-menu">
  <a href="<!-- TMPL_VAR path-prefix -->/">
    <!-- TMPL_IF has-nyan -->
        <img class="nyan-logo" src="<!-- TMPL_VAR path-prefix -->/images/chem-nyan/chem-nyan.gif">
    <!-- TMPL_ELSE -->
        <img src="<!-- TMPL_VAR path-prefix -->/images/lab-logo.svg">
    <!-- /TMPL_IF -->
  </a>
  <!-- TMPL_IF has-nyan -->
    <p class="nyan-caption">Let's chem-nyan!</p>
  <!-- /TMPL_IF -->

  <ul>
    <li class="menu-level-1">Safety</li>
    <li class="menu-level-2">
      <ul>
	<li>
	  <a href="<!-- TMPL_VAR manage-ghs-hazard -->">
	    GHS Hazard Codes
	  </a>
	</li>
	<li class="menu-level-2">
	  <a href="<!-- TMPL_VAR manage-ghs-precaution -->">
	    GHS precautionary statements
	  </a>
	</li>
	<li class="menu-level-2">
	  <a href="<!-- TMPL_VAR manage-cer -->">
	    CER codes
	  </a>
	</li>
	<li class="menu-level-2">
	  <a href="<!-- TMPL_VAR manage-adr -->">
	    ADR codes
	  </a>
	</li>
	<li class="menu-level-2">
	  <a href="<!-- TMPL_VAR waste-letter -->">
	    Hazardous waste form
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR l-factor-calculator -->">
	    Chemical risk calculator
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR l-factor-calculator-carc -->">
	    Chemical risk calculator (carcinogenic)
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR store-classify-tree -->">
	    Chemical classifications for safe storage.
	  </a>
	</li>

      </ul>
    </li>
    <li class="menu-level-1">Places</li>
    <li class="menu-level-2">
      <ul>
	<li>
	  <a href="<!-- TMPL_VAR manage-address -->">
	    Address
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR manage-building -->">
	    Building
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR manage-maps -->">
	    Maps
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR manage-storage -->">
	    Storage
	  </a>
	</li>
      </ul>
    </li>
    <li class="menu-level-1">Chemical compounds</li>
    <li class="menu-level-2">
      <ul>
	<li>
	  <a href="<!-- TMPL_VAR manage-chemicals -->">
	    Compound
	  </a>
	</li>
      </ul>
    </li>
    <li class="menu-level-1">Chemical products</li>
    <li class="menu-level-2">
      <ul>
	<li>
	  <a href="<!-- TMPL_VAR manage-chemical-products -->">
	    Managing
	  </a>
	</li>
      </ul>
    </li>

    <li class="menu-level-1">Users</li>
    <li class="menu-level-2">
      <ul>
	<li>
	  <a href="<!-- TMPL_VAR manage-user -->">
	    Manage users
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR change-password -->">
	    Change password
	  </a>
	</li>
	<li>
	  <a href="<!-- TMPL_VAR user-preferences -->">
	    User preferences
	  </a>
	</li>

      </ul>
    </li>

  </ul>
</div>
