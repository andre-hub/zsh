



<!DOCTYPE html>
<html lang="en" class="">
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# object: http://ogp.me/ns/object# article: http://ogp.me/ns/article# profile: http://ogp.me/ns/profile#">
    <meta charset='utf-8'>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta http-equiv="Content-Language" content="en">
    
    
    <title>zsh-git-prompt/gitstatus.py at master · olivierverdier/zsh-git-prompt · GitHub</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub">
    <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub">
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-touch-icon-114.png">
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-touch-icon-114.png">
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-touch-icon-144.png">
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-touch-icon-144.png">
    <meta property="fb:app_id" content="1401488693436528">

      <meta content="@github" name="twitter:site" /><meta content="summary" name="twitter:card" /><meta content="olivierverdier/zsh-git-prompt" name="twitter:title" /><meta content="zsh-git-prompt - Informative git prompt for zsh" name="twitter:description" /><meta content="https://avatars3.githubusercontent.com/u/198281?v=2&amp;s=400" name="twitter:image:src" />
<meta content="GitHub" property="og:site_name" /><meta content="object" property="og:type" /><meta content="https://avatars3.githubusercontent.com/u/198281?v=2&amp;s=400" property="og:image" /><meta content="olivierverdier/zsh-git-prompt" property="og:title" /><meta content="https://github.com/olivierverdier/zsh-git-prompt" property="og:url" /><meta content="zsh-git-prompt - Informative git prompt for zsh" property="og:description" />

      <meta name="browser-stats-url" content="/_stats">
    <link rel="assets" href="https://assets-cdn.github.com/">
    <link rel="conduit-xhr" href="https://ghconduit.com:25035">
    
    <meta name="pjax-timeout" content="1000">

    <meta name="msapplication-TileImage" content="/windows-tile.png">
    <meta name="msapplication-TileColor" content="#ffffff">
    <meta name="selected-link" value="repo_source" data-pjax-transient>
      <meta name="google-analytics" content="UA-3769691-2">

    <meta content="collector.githubapp.com" name="octolytics-host" /><meta content="collector-cdn.github.com" name="octolytics-script-host" /><meta content="github" name="octolytics-app-id" /><meta content="C3D8EB4F:4AB3:1247CEE:5450EEF6" name="octolytics-dimension-request_id" />
    
    <meta content="Rails, view, blob#show" name="analytics-event" />

    
    
    <link rel="icon" type="image/x-icon" href="https://assets-cdn.github.com/favicon.ico">


    <meta content="authenticity_token" name="csrf-param" />
<meta content="XpOwxAY3Dcv8yYJZ5LSVveczwlBYFvA4oY3cnJ/GSfYDx8q4ZOySMTlhly+j3JUc9jkNAJlmnPpfLNXSWJ+XVw==" name="csrf-token" />

    <link href="https://assets-cdn.github.com/assets/github-6904dbee2d843b3c29d5a545bbc318e58561a031f6796d153ccf896bb306590c.css" media="all" rel="stylesheet" type="text/css" />
    <link href="https://assets-cdn.github.com/assets/github2-9d91e75a6fa06167f161d924f9f7197db187c2455dad4460725a13a1c3cffdfd.css" media="all" rel="stylesheet" type="text/css" />
    
    


    <meta http-equiv="x-pjax-version" content="9a174fbd7d9f203f6725de9d23fd2263">

      
  <meta name="description" content="zsh-git-prompt - Informative git prompt for zsh">
  <meta name="go-import" content="github.com/olivierverdier/zsh-git-prompt git https://github.com/olivierverdier/zsh-git-prompt.git">

  <meta content="198281" name="octolytics-dimension-user_id" /><meta content="olivierverdier" name="octolytics-dimension-user_login" /><meta content="638566" name="octolytics-dimension-repository_id" /><meta content="olivierverdier/zsh-git-prompt" name="octolytics-dimension-repository_nwo" /><meta content="true" name="octolytics-dimension-repository_public" /><meta content="false" name="octolytics-dimension-repository_is_fork" /><meta content="638566" name="octolytics-dimension-repository_network_root_id" /><meta content="olivierverdier/zsh-git-prompt" name="octolytics-dimension-repository_network_root_nwo" />
  <link href="https://github.com/olivierverdier/zsh-git-prompt/commits/master.atom" rel="alternate" title="Recent Commits to zsh-git-prompt:master" type="application/atom+xml">

  </head>


  <body class="logged_out  env-production windows vis-public page-blob">
    <a href="#start-of-content" tabindex="1" class="accessibility-aid js-skip-to-content">Skip to content</a>
    <div class="wrapper">
      
      
      
      


      
      <div class="header header-logged-out" role="banner">
  <div class="container clearfix">

    <a class="header-logo-wordmark" href="https://github.com/" ga-data-click="(Logged out) Header, go to homepage, icon:logo-wordmark">
      <span class="mega-octicon octicon-logo-github"></span>
    </a>

    <div class="header-actions" role="navigation">
        <a class="button primary" href="/join" data-ga-click="(Logged out) Header, clicked Sign up, text:sign-up">Sign up</a>
      <a class="button signin" href="/login?return_to=%2Folivierverdier%2Fzsh-git-prompt%2Fblob%2Fmaster%2Fgitstatus.py" data-ga-click="(Logged out) Header, clicked Sign in, text:sign-in">Sign in</a>
    </div>

    <div class="site-search repo-scope js-site-search" role="search">
      <form accept-charset="UTF-8" action="/olivierverdier/zsh-git-prompt/search" class="js-site-search-form" data-global-search-url="/search" data-repo-search-url="/olivierverdier/zsh-git-prompt/search" method="get"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>
  <input type="text"
    class="js-site-search-field is-clearable"
    data-hotkey="s"
    name="q"
    placeholder="Search"
    data-global-scope-placeholder="Search GitHub"
    data-repo-scope-placeholder="Search"
    tabindex="1"
    autocapitalize="off">
  <div class="scope-badge">This repository</div>
</form>
    </div>

      <ul class="header-nav left" role="navigation">
          <li class="header-nav-item">
            <a class="header-nav-link" href="/explore" data-ga-click="(Logged out) Header, go to explore, text:explore">Explore</a>
          </li>
          <li class="header-nav-item">
            <a class="header-nav-link" href="/features" data-ga-click="(Logged out) Header, go to features, text:features">Features</a>
          </li>
          <li class="header-nav-item">
            <a class="header-nav-link" href="https://enterprise.github.com/" data-ga-click="(Logged out) Header, go to enterprise, text:enterprise">Enterprise</a>
          </li>
          <li class="header-nav-item">
            <a class="header-nav-link" href="/blog" data-ga-click="(Logged out) Header, go to blog, text:blog">Blog</a>
          </li>
      </ul>

  </div>
</div>



      <div id="start-of-content" class="accessibility-aid"></div>
          <div class="site" itemscope itemtype="http://schema.org/WebPage">
    <div id="js-flash-container">
      
    </div>
    <div class="pagehead repohead instapaper_ignore readability-menu">
      <div class="container">
        
<ul class="pagehead-actions">


  <li>
      <a href="/login?return_to=%2Folivierverdier%2Fzsh-git-prompt"
    class="minibutton with-count star-button tooltipped tooltipped-n"
    aria-label="You must be signed in to star a repository" rel="nofollow">
    <span class="octicon octicon-star"></span>
    Star
  </a>

    <a class="social-count js-social-count" href="/olivierverdier/zsh-git-prompt/stargazers">
      462
    </a>

  </li>

    <li>
      <a href="/login?return_to=%2Folivierverdier%2Fzsh-git-prompt"
        class="minibutton with-count js-toggler-target fork-button tooltipped tooltipped-n"
        aria-label="You must be signed in to fork a repository" rel="nofollow">
        <span class="octicon octicon-repo-forked"></span>
        Fork
      </a>
      <a href="/olivierverdier/zsh-git-prompt/network" class="social-count">
        139
      </a>
    </li>
</ul>

        <h1 itemscope itemtype="http://data-vocabulary.org/Breadcrumb" class="entry-title public">
          <span class="mega-octicon octicon-repo"></span>
          <span class="author"><a href="/olivierverdier" class="url fn" itemprop="url" rel="author"><span itemprop="title">olivierverdier</span></a></span><!--
       --><span class="path-divider">/</span><!--
       --><strong><a href="/olivierverdier/zsh-git-prompt" class="js-current-repository js-repo-home-link" data-pjax-container-selector="#js-repo-pjax-container">zsh-git-prompt</a></strong>

          <span class="page-context-loader">
            <img alt="" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
          </span>

        </h1>
      </div><!-- /.container -->
    </div><!-- /.repohead -->

    <div class="container">
      <div class="repository-with-sidebar repo-container new-discussion-timeline  ">
        <div class="repository-sidebar clearfix">
            
<div class="sunken-menu vertical-right repo-nav js-repo-nav js-sidenav-container-pjax js-octicon-loaders" role="navigation" data-issue-count-url="/olivierverdier/zsh-git-prompt/issues/counts" data-pjax-container-selector="#js-repo-pjax-container">
  <div class="sunken-menu-contents">
    <ul class="sunken-menu-group">
      <li class="tooltipped tooltipped-w" aria-label="Code">
        <a href="/olivierverdier/zsh-git-prompt" aria-label="Code" class="selected js-selected-navigation-item sunken-menu-item" data-hotkey="g c" data-pjax="true" data-selected-links="repo_source repo_downloads repo_commits repo_releases repo_tags repo_branches /olivierverdier/zsh-git-prompt">
          <span class="octicon octicon-code"></span> <span class="full-word">Code</span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

        <li class="tooltipped tooltipped-w" aria-label="Issues">
          <a href="/olivierverdier/zsh-git-prompt/issues" aria-label="Issues" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-hotkey="g i" data-selected-links="repo_issues repo_labels repo_milestones /olivierverdier/zsh-git-prompt/issues">
            <span class="octicon octicon-issue-opened"></span> <span class="full-word">Issues</span>
            <span class="js-issue-replace-counter"></span>
            <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>        </li>

      <li class="tooltipped tooltipped-w" aria-label="Pull Requests">
        <a href="/olivierverdier/zsh-git-prompt/pulls" aria-label="Pull Requests" class="js-selected-navigation-item sunken-menu-item js-disable-pjax" data-hotkey="g p" data-selected-links="repo_pulls /olivierverdier/zsh-git-prompt/pulls">
            <span class="octicon octicon-git-pull-request"></span> <span class="full-word">Pull Requests</span>
            <span class="js-pull-replace-counter"></span>
            <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>


    </ul>
    <div class="sunken-menu-separator"></div>
    <ul class="sunken-menu-group">

      <li class="tooltipped tooltipped-w" aria-label="Pulse">
        <a href="/olivierverdier/zsh-git-prompt/pulse/weekly" aria-label="Pulse" class="js-selected-navigation-item sunken-menu-item" data-pjax="true" data-selected-links="pulse /olivierverdier/zsh-git-prompt/pulse/weekly">
          <span class="octicon octicon-pulse"></span> <span class="full-word">Pulse</span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

      <li class="tooltipped tooltipped-w" aria-label="Graphs">
        <a href="/olivierverdier/zsh-git-prompt/graphs" aria-label="Graphs" class="js-selected-navigation-item sunken-menu-item" data-pjax="true" data-selected-links="repo_graphs repo_contributors /olivierverdier/zsh-git-prompt/graphs">
          <span class="octicon octicon-graph"></span> <span class="full-word">Graphs</span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>
    </ul>


  </div>
</div>

              <div class="only-with-full-nav">
                
  
<div class="clone-url open"
  data-protocol-type="http"
  data-url="/users/set_protocol?protocol_selector=http&amp;protocol_type=clone">
  <h3><span class="text-emphasized">HTTPS</span> clone URL</h3>
  <div class="input-group">
    <input type="text" class="input-mini input-monospace js-url-field"
           value="https://github.com/olivierverdier/zsh-git-prompt.git" readonly="readonly">
    <span class="input-group-button">
      <button aria-label="Copy to clipboard" class="js-zeroclipboard minibutton zeroclipboard-button" data-clipboard-text="https://github.com/olivierverdier/zsh-git-prompt.git" data-copied-hint="Copied!" type="button"><span class="octicon octicon-clippy"></span></button>
    </span>
  </div>
</div>

  
<div class="clone-url "
  data-protocol-type="subversion"
  data-url="/users/set_protocol?protocol_selector=subversion&amp;protocol_type=clone">
  <h3><span class="text-emphasized">Subversion</span> checkout URL</h3>
  <div class="input-group">
    <input type="text" class="input-mini input-monospace js-url-field"
           value="https://github.com/olivierverdier/zsh-git-prompt" readonly="readonly">
    <span class="input-group-button">
      <button aria-label="Copy to clipboard" class="js-zeroclipboard minibutton zeroclipboard-button" data-clipboard-text="https://github.com/olivierverdier/zsh-git-prompt" data-copied-hint="Copied!" type="button"><span class="octicon octicon-clippy"></span></button>
    </span>
  </div>
</div>


<p class="clone-options">You can clone with
      <a href="#" class="js-clone-selector" data-protocol="http">HTTPS</a>
      or <a href="#" class="js-clone-selector" data-protocol="subversion">Subversion</a>.
  <a href="https://help.github.com/articles/which-remote-url-should-i-use" class="help tooltipped tooltipped-n" aria-label="Get help on which URL is right for you.">
    <span class="octicon octicon-question"></span>
  </a>
</p>


  <a href="http://windows.github.com" class="minibutton sidebar-button" title="Save olivierverdier/zsh-git-prompt to your computer and use it in GitHub Desktop." aria-label="Save olivierverdier/zsh-git-prompt to your computer and use it in GitHub Desktop.">
    <span class="octicon octicon-device-desktop"></span>
    Clone in Desktop
  </a>

                <a href="/olivierverdier/zsh-git-prompt/archive/master.zip"
                   class="minibutton sidebar-button"
                   aria-label="Download the contents of olivierverdier/zsh-git-prompt as a zip file"
                   title="Download the contents of olivierverdier/zsh-git-prompt as a zip file"
                   rel="nofollow">
                  <span class="octicon octicon-cloud-download"></span>
                  Download ZIP
                </a>
              </div>
        </div><!-- /.repository-sidebar -->

        <div id="js-repo-pjax-container" class="repository-content context-loader-container" data-pjax-container>
          

<a href="/olivierverdier/zsh-git-prompt/blob/1c96fe2a6a36653301144b8182ffc7cf063e1f3e/gitstatus.py" class="hidden js-permalink-shortcut" data-hotkey="y">Permalink</a>

<!-- blob contrib key: blob_contributors:v21:ae054aaaac068f8fe7463b8e47c994c1 -->

<div class="file-navigation">
  
<div class="select-menu js-menu-container js-select-menu left">
  <span class="minibutton select-menu-button js-menu-target css-truncate" data-hotkey="w"
    data-master-branch="master"
    data-ref="master"
    title="master"
    role="button" aria-label="Switch branches or tags" tabindex="0" aria-haspopup="true">
    <span class="octicon octicon-git-branch"></span>
    <i>branch:</i>
    <span class="js-select-button css-truncate-target">master</span>
  </span>

  <div class="select-menu-modal-holder js-menu-content js-navigation-container" data-pjax aria-hidden="true">

    <div class="select-menu-modal">
      <div class="select-menu-header">
        <span class="select-menu-title">Switch branches/tags</span>
        <span class="octicon octicon-x js-menu-close" role="button" aria-label="Close"></span>
      </div> <!-- /.select-menu-header -->

      <div class="select-menu-filters">
        <div class="select-menu-text-filter">
          <input type="text" aria-label="Filter branches/tags" id="context-commitish-filter-field" class="js-filterable-field js-navigation-enable" placeholder="Filter branches/tags">
        </div>
        <div class="select-menu-tabs">
          <ul>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="branches" class="js-select-menu-tab">Branches</a>
            </li>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="tags" class="js-select-menu-tab">Tags</a>
            </li>
          </ul>
        </div><!-- /.select-menu-tabs -->
      </div><!-- /.select-menu-filters -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="branches">

        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <div class="select-menu-item js-navigation-item selected">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/olivierverdier/zsh-git-prompt/blob/master/gitstatus.py"
                 data-name="master"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text css-truncate-target"
                 title="master">master</a>
            </div> <!-- /.select-menu-item -->
        </div>

          <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="tags">
        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/olivierverdier/zsh-git-prompt/tree/v0.4/gitstatus.py"
                 data-name="v0.4"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text css-truncate-target"
                 title="v0.4">v0.4</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/olivierverdier/zsh-git-prompt/tree/v0.3/gitstatus.py"
                 data-name="v0.3"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text css-truncate-target"
                 title="v0.3">v0.3</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/olivierverdier/zsh-git-prompt/tree/v0.2/gitstatus.py"
                 data-name="v0.2"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text css-truncate-target"
                 title="v0.2">v0.2</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/olivierverdier/zsh-git-prompt/tree/v0.1b/gitstatus.py"
                 data-name="v0.1b"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text css-truncate-target"
                 title="v0.1b">v0.1b</a>
            </div> <!-- /.select-menu-item -->
            <div class="select-menu-item js-navigation-item ">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <a href="/olivierverdier/zsh-git-prompt/tree/v0.1a/gitstatus.py"
                 data-name="v0.1a"
                 data-skip-pjax="true"
                 rel="nofollow"
                 class="js-navigation-open select-menu-item-text css-truncate-target"
                 title="v0.1a">v0.1a</a>
            </div> <!-- /.select-menu-item -->
        </div>

        <div class="select-menu-no-results">Nothing to show</div>
      </div> <!-- /.select-menu-list -->

    </div> <!-- /.select-menu-modal -->
  </div> <!-- /.select-menu-modal-holder -->
</div> <!-- /.select-menu -->

  <div class="button-group right">
    <a href="/olivierverdier/zsh-git-prompt/find/master"
          class="js-show-file-finder minibutton empty-icon tooltipped tooltipped-s"
          data-pjax
          data-hotkey="t"
          aria-label="Quickly jump between files">
      <span class="octicon octicon-list-unordered"></span>
    </a>
    <button class="js-zeroclipboard minibutton zeroclipboard-button"
          data-clipboard-text="gitstatus.py"
          aria-label="Copy to clipboard"
          data-copied-hint="Copied!">
      <span class="octicon octicon-clippy"></span>
    </button>
  </div>

  <div class="breadcrumb">
    <span class='repo-root js-repo-root'><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/olivierverdier/zsh-git-prompt" class="" data-branch="master" data-direction="back" data-pjax="true" itemscope="url"><span itemprop="title">zsh-git-prompt</span></a></span></span><span class="separator"> / </span><strong class="final-path">gitstatus.py</strong>
  </div>
</div>


  <div class="commit file-history-tease">
    <div class="file-history-tease-header">
        <img alt="Olivier Verdier" class="avatar" data-user="198281" height="24" src="https://avatars2.githubusercontent.com/u/198281?v=2&amp;s=48" width="24" />
        <span class="author"><a href="/olivierverdier" rel="author">olivierverdier</a></span>
        <time datetime="2014-09-02T15:58:24Z" is="relative-time">Sep 2, 2014</time>
        <div class="commit-title">
            <a href="/olivierverdier/zsh-git-prompt/commit/ba32c5c8c4f780c33fb59d5ec8aab00153658c8e" class="message" data-pjax="true" title="unicode and compatibility with Python 3

the code should now run equally well with Python 2 and 3">unicode and compatibility with Python 3</a>
        </div>
    </div>

    <div class="participation">
      <p class="quickstat">
        <a href="#blob_contributors_box" rel="facebox">
          <strong>1</strong>
           contributor
        </a>
      </p>
      
    </div>
    <div id="blob_contributors_box" style="display:none">
      <h2 class="facebox-header">Users who have contributed to this file</h2>
      <ul class="facebox-user-list">
          <li class="facebox-user-list-item">
            <img alt="Olivier Verdier" data-user="198281" height="24" src="https://avatars2.githubusercontent.com/u/198281?v=2&amp;s=48" width="24" />
            <a href="/olivierverdier">olivierverdier</a>
          </li>
      </ul>
    </div>
  </div>

<div class="file-box">
  <div class="file">
    <div class="meta clearfix">
      <div class="info file-name">
          <span class="mode" title="File mode">executable file</span>
          <span class="meta-divider"></span>
          <span>66 lines (54 sloc)</span>
          <span class="meta-divider"></span>
        <span>2.316 kb</span>
      </div>
      <div class="actions">
        <div class="button-group">
          <a href="/olivierverdier/zsh-git-prompt/raw/master/gitstatus.py" class="minibutton " id="raw-url">Raw</a>
            <a href="/olivierverdier/zsh-git-prompt/blame/master/gitstatus.py" class="minibutton js-update-url-with-hash">Blame</a>
          <a href="/olivierverdier/zsh-git-prompt/commits/master/gitstatus.py" class="minibutton " rel="nofollow">History</a>
        </div><!-- /.button-group -->

          <a class="octicon-button tooltipped tooltipped-nw"
             href="http://windows.github.com" aria-label="Open this file in GitHub for Windows">
              <span class="octicon octicon-device-desktop"></span>
          </a>

            <a class="octicon-button disabled tooltipped tooltipped-w" href="#"
               aria-label="You must be signed in to make or propose changes"><span class="octicon octicon-pencil"></span></a>

          <a class="octicon-button danger disabled tooltipped tooltipped-w" href="#"
             aria-label="You must be signed in to make or propose changes">
          <span class="octicon octicon-trashcan"></span>
        </a>
      </div><!-- /.actions -->
    </div>
    
  <div class="blob-wrapper data type-python">
      <table class="highlight tab-size-8 js-file-line-container">
      <tr>
        <td id="L1" class="blob-num js-line-number" data-line-number="1"></td>
        <td id="LC1" class="blob-code js-file-line"><span class="c">#!/usr/bin/env python</span></td>
      </tr>
      <tr>
        <td id="L2" class="blob-num js-line-number" data-line-number="2"></td>
        <td id="LC2" class="blob-code js-file-line"><span class="kn">from</span> <span class="nn">__future__</span> <span class="kn">import</span> <span class="n">print_function</span></td>
      </tr>
      <tr>
        <td id="L3" class="blob-num js-line-number" data-line-number="3"></td>
        <td id="LC3" class="blob-code js-file-line">
</td>
      </tr>
      <tr>
        <td id="L4" class="blob-num js-line-number" data-line-number="4"></td>
        <td id="LC4" class="blob-code js-file-line"><span class="c"># change this symbol to whatever you prefer</span></td>
      </tr>
      <tr>
        <td id="L5" class="blob-num js-line-number" data-line-number="5"></td>
        <td id="LC5" class="blob-code js-file-line"><span class="n">prehash</span> <span class="o">=</span> <span class="s">&#39;:&#39;</span></td>
      </tr>
      <tr>
        <td id="L6" class="blob-num js-line-number" data-line-number="6"></td>
        <td id="LC6" class="blob-code js-file-line">
</td>
      </tr>
      <tr>
        <td id="L7" class="blob-num js-line-number" data-line-number="7"></td>
        <td id="LC7" class="blob-code js-file-line"><span class="kn">from</span> <span class="nn">subprocess</span> <span class="kn">import</span> <span class="n">Popen</span><span class="p">,</span> <span class="n">PIPE</span></td>
      </tr>
      <tr>
        <td id="L8" class="blob-num js-line-number" data-line-number="8"></td>
        <td id="LC8" class="blob-code js-file-line">
</td>
      </tr>
      <tr>
        <td id="L9" class="blob-num js-line-number" data-line-number="9"></td>
        <td id="LC9" class="blob-code js-file-line"><span class="kn">import</span> <span class="nn">sys</span></td>
      </tr>
      <tr>
        <td id="L10" class="blob-num js-line-number" data-line-number="10"></td>
        <td id="LC10" class="blob-code js-file-line"><span class="n">gitsym</span> <span class="o">=</span> <span class="n">Popen</span><span class="p">([</span><span class="s">&#39;git&#39;</span><span class="p">,</span> <span class="s">&#39;symbolic-ref&#39;</span><span class="p">,</span> <span class="s">&#39;HEAD&#39;</span><span class="p">],</span> <span class="n">stdout</span><span class="o">=</span><span class="n">PIPE</span><span class="p">,</span> <span class="n">stderr</span><span class="o">=</span><span class="n">PIPE</span><span class="p">)</span></td>
      </tr>
      <tr>
        <td id="L11" class="blob-num js-line-number" data-line-number="11"></td>
        <td id="LC11" class="blob-code js-file-line"><span class="n">branch</span><span class="p">,</span> <span class="n">error</span> <span class="o">=</span> <span class="n">gitsym</span><span class="o">.</span><span class="n">communicate</span><span class="p">()</span></td>
      </tr>
      <tr>
        <td id="L12" class="blob-num js-line-number" data-line-number="12"></td>
        <td id="LC12" class="blob-code js-file-line">
</td>
      </tr>
      <tr>
        <td id="L13" class="blob-num js-line-number" data-line-number="13"></td>
        <td id="LC13" class="blob-code js-file-line"><span class="n">error_string</span> <span class="o">=</span> <span class="n">error</span><span class="o">.</span><span class="n">decode</span><span class="p">(</span><span class="s">&#39;utf-8&#39;</span><span class="p">)</span></td>
      </tr>
      <tr>
        <td id="L14" class="blob-num js-line-number" data-line-number="14"></td>
        <td id="LC14" class="blob-code js-file-line">
</td>
      </tr>
      <tr>
        <td id="L15" class="blob-num js-line-number" data-line-number="15"></td>
        <td id="LC15" class="blob-code js-file-line"><span class="k">if</span> <span class="s">&#39;fatal: Not a git repository&#39;</span> <span class="ow">in</span> <span class="n">error_string</span><span class="p">:</span></td>
      </tr>
      <tr>
        <td id="L16" class="blob-num js-line-number" data-line-number="16"></td>
        <td id="LC16" class="blob-code js-file-line">	<span class="n">sys</span><span class="o">.</span><span class="n">exit</span><span class="p">(</span><span class="mi">0</span><span class="p">)</span></td>
      </tr>
      <tr>
        <td id="L17" class="blob-num js-line-number" data-line-number="17"></td>
        <td id="LC17" class="blob-code js-file-line">
</td>
      </tr>
      <tr>
        <td id="L18" class="blob-num js-line-number" data-line-number="18"></td>
        <td id="LC18" class="blob-code js-file-line"><span class="n">branch</span> <span class="o">=</span> <span class="n">branch</span><span class="o">.</span><span class="n">decode</span><span class="p">(</span><span class="s">&quot;utf-8&quot;</span><span class="p">)</span><span class="o">.</span><span class="n">strip</span><span class="p">()[</span><span class="mi">11</span><span class="p">:]</span></td>
      </tr>
      <tr>
        <td id="L19" class="blob-num js-line-number" data-line-number="19"></td>
        <td id="LC19" class="blob-code js-file-line">
</td>
      </tr>
      <tr>
        <td id="L20" class="blob-num js-line-number" data-line-number="20"></td>
        <td id="LC20" class="blob-code js-file-line"><span class="n">res</span><span class="p">,</span> <span class="n">err</span> <span class="o">=</span> <span class="n">Popen</span><span class="p">([</span><span class="s">&#39;git&#39;</span><span class="p">,</span><span class="s">&#39;diff&#39;</span><span class="p">,</span><span class="s">&#39;--name-status&#39;</span><span class="p">],</span> <span class="n">stdout</span><span class="o">=</span><span class="n">PIPE</span><span class="p">,</span> <span class="n">stderr</span><span class="o">=</span><span class="n">PIPE</span><span class="p">)</span><span class="o">.</span><span class="n">communicate</span><span class="p">()</span></td>
      </tr>
      <tr>
        <td id="L21" class="blob-num js-line-number" data-line-number="21"></td>
        <td id="LC21" class="blob-code js-file-line"><span class="n">err_string</span> <span class="o">=</span> <span class="n">err</span><span class="o">.</span><span class="n">decode</span><span class="p">(</span><span class="s">&#39;utf-8&#39;</span><span class="p">)</span></td>
      </tr>
      <tr>
        <td id="L22" class="blob-num js-line-number" data-line-number="22"></td>
        <td id="LC22" class="blob-code js-file-line"><span class="k">if</span> <span class="s">&#39;fatal&#39;</span> <span class="ow">in</span> <span class="n">err_string</span><span class="p">:</span></td>
      </tr>
      <tr>
        <td id="L23" class="blob-num js-line-number" data-line-number="23"></td>
        <td id="LC23" class="blob-code js-file-line">	<span class="n">sys</span><span class="o">.</span><span class="n">exit</span><span class="p">(</span><span class="mi">0</span><span class="p">)</span></td>
      </tr>
      <tr>
        <td id="L24" class="blob-num js-line-number" data-line-number="24"></td>
        <td id="LC24" class="blob-code js-file-line"><span class="n">changed_files</span> <span class="o">=</span> <span class="p">[</span><span class="n">namestat</span><span class="p">[</span><span class="mi">0</span><span class="p">]</span> <span class="k">for</span> <span class="n">namestat</span> <span class="ow">in</span> <span class="n">res</span><span class="o">.</span><span class="n">decode</span><span class="p">(</span><span class="s">&quot;utf-8&quot;</span><span class="p">)</span><span class="o">.</span><span class="n">splitlines</span><span class="p">()]</span></td>
      </tr>
      <tr>
        <td id="L25" class="blob-num js-line-number" data-line-number="25"></td>
        <td id="LC25" class="blob-code js-file-line"><span class="n">staged_files</span> <span class="o">=</span> <span class="p">[</span><span class="n">namestat</span><span class="p">[</span><span class="mi">0</span><span class="p">]</span> <span class="k">for</span> <span class="n">namestat</span> <span class="ow">in</span> <span class="n">Popen</span><span class="p">([</span><span class="s">&#39;git&#39;</span><span class="p">,</span><span class="s">&#39;diff&#39;</span><span class="p">,</span> <span class="s">&#39;--staged&#39;</span><span class="p">,</span><span class="s">&#39;--name-status&#39;</span><span class="p">],</span> <span class="n">stdout</span><span class="o">=</span><span class="n">PIPE</span><span class="p">)</span><span class="o">.</span><span class="n">communicate</span><span class="p">()[</span><span class="mi">0</span><span class="p">]</span><span class="o">.</span><span class="n">splitlines</span><span class="p">()]</span></td>
      </tr>
      <tr>
        <td id="L26" class="blob-num js-line-number" data-line-number="26"></td>
        <td id="LC26" class="blob-code js-file-line"><span class="n">nb_changed</span> <span class="o">=</span> <span class="nb">len</span><span class="p">(</span><span class="n">changed_files</span><span class="p">)</span> <span class="o">-</span> <span class="n">changed_files</span><span class="o">.</span><span class="n">count</span><span class="p">(</span><span class="s">&#39;U&#39;</span><span class="p">)</span></td>
      </tr>
      <tr>
        <td id="L27" class="blob-num js-line-number" data-line-number="27"></td>
        <td id="LC27" class="blob-code js-file-line"><span class="n">nb_U</span> <span class="o">=</span> <span class="n">staged_files</span><span class="o">.</span><span class="n">count</span><span class="p">(</span><span class="s">&#39;U&#39;</span><span class="p">)</span></td>
      </tr>
      <tr>
        <td id="L28" class="blob-num js-line-number" data-line-number="28"></td>
        <td id="LC28" class="blob-code js-file-line"><span class="n">nb_staged</span> <span class="o">=</span> <span class="nb">len</span><span class="p">(</span><span class="n">staged_files</span><span class="p">)</span> <span class="o">-</span> <span class="n">nb_U</span></td>
      </tr>
      <tr>
        <td id="L29" class="blob-num js-line-number" data-line-number="29"></td>
        <td id="LC29" class="blob-code js-file-line"><span class="n">staged</span> <span class="o">=</span> <span class="nb">str</span><span class="p">(</span><span class="n">nb_staged</span><span class="p">)</span></td>
      </tr>
      <tr>
        <td id="L30" class="blob-num js-line-number" data-line-number="30"></td>
        <td id="LC30" class="blob-code js-file-line"><span class="n">conflicts</span> <span class="o">=</span> <span class="nb">str</span><span class="p">(</span><span class="n">nb_U</span><span class="p">)</span></td>
      </tr>
      <tr>
        <td id="L31" class="blob-num js-line-number" data-line-number="31"></td>
        <td id="LC31" class="blob-code js-file-line"><span class="n">changed</span> <span class="o">=</span> <span class="nb">str</span><span class="p">(</span><span class="n">nb_changed</span><span class="p">)</span></td>
      </tr>
      <tr>
        <td id="L32" class="blob-num js-line-number" data-line-number="32"></td>
        <td id="LC32" class="blob-code js-file-line"><span class="n">nb_untracked</span> <span class="o">=</span> <span class="nb">len</span><span class="p">([</span><span class="mi">0</span> <span class="k">for</span> <span class="n">status</span> <span class="ow">in</span> <span class="n">Popen</span><span class="p">([</span><span class="s">&#39;git&#39;</span><span class="p">,</span><span class="s">&#39;status&#39;</span><span class="p">,</span><span class="s">&#39;--porcelain&#39;</span><span class="p">,],</span><span class="n">stdout</span><span class="o">=</span><span class="n">PIPE</span><span class="p">)</span><span class="o">.</span><span class="n">communicate</span><span class="p">()[</span><span class="mi">0</span><span class="p">]</span><span class="o">.</span><span class="n">decode</span><span class="p">(</span><span class="s">&quot;utf-8&quot;</span><span class="p">)</span><span class="o">.</span><span class="n">splitlines</span><span class="p">()</span> <span class="k">if</span> <span class="n">status</span><span class="o">.</span><span class="n">startswith</span><span class="p">(</span><span class="s">&#39;??&#39;</span><span class="p">)])</span></td>
      </tr>
      <tr>
        <td id="L33" class="blob-num js-line-number" data-line-number="33"></td>
        <td id="LC33" class="blob-code js-file-line"><span class="n">untracked</span> <span class="o">=</span> <span class="nb">str</span><span class="p">(</span><span class="n">nb_untracked</span><span class="p">)</span></td>
      </tr>
      <tr>
        <td id="L34" class="blob-num js-line-number" data-line-number="34"></td>
        <td id="LC34" class="blob-code js-file-line">
</td>
      </tr>
      <tr>
        <td id="L35" class="blob-num js-line-number" data-line-number="35"></td>
        <td id="LC35" class="blob-code js-file-line"><span class="n">ahead</span><span class="p">,</span> <span class="n">behind</span> <span class="o">=</span> <span class="mi">0</span><span class="p">,</span><span class="mi">0</span></td>
      </tr>
      <tr>
        <td id="L36" class="blob-num js-line-number" data-line-number="36"></td>
        <td id="LC36" class="blob-code js-file-line">
</td>
      </tr>
      <tr>
        <td id="L37" class="blob-num js-line-number" data-line-number="37"></td>
        <td id="LC37" class="blob-code js-file-line"><span class="k">if</span> <span class="ow">not</span> <span class="n">branch</span><span class="p">:</span> <span class="c"># not on any branch</span></td>
      </tr>
      <tr>
        <td id="L38" class="blob-num js-line-number" data-line-number="38"></td>
        <td id="LC38" class="blob-code js-file-line">	<span class="n">branch</span> <span class="o">=</span> <span class="n">prehash</span> <span class="o">+</span> <span class="n">Popen</span><span class="p">([</span><span class="s">&#39;git&#39;</span><span class="p">,</span><span class="s">&#39;rev-parse&#39;</span><span class="p">,</span><span class="s">&#39;--short&#39;</span><span class="p">,</span><span class="s">&#39;HEAD&#39;</span><span class="p">],</span> <span class="n">stdout</span><span class="o">=</span><span class="n">PIPE</span><span class="p">)</span><span class="o">.</span><span class="n">communicate</span><span class="p">()[</span><span class="mi">0</span><span class="p">]</span><span class="o">.</span><span class="n">decode</span><span class="p">(</span><span class="s">&quot;utf-8&quot;</span><span class="p">)[:</span><span class="o">-</span><span class="mi">1</span><span class="p">]</span></td>
      </tr>
      <tr>
        <td id="L39" class="blob-num js-line-number" data-line-number="39"></td>
        <td id="LC39" class="blob-code js-file-line"><span class="k">else</span><span class="p">:</span></td>
      </tr>
      <tr>
        <td id="L40" class="blob-num js-line-number" data-line-number="40"></td>
        <td id="LC40" class="blob-code js-file-line">	<span class="n">remote_name</span> <span class="o">=</span> <span class="n">Popen</span><span class="p">([</span><span class="s">&#39;git&#39;</span><span class="p">,</span><span class="s">&#39;config&#39;</span><span class="p">,</span><span class="s">&#39;branch.</span><span class="si">%s</span><span class="s">.remote&#39;</span> <span class="o">%</span> <span class="n">branch</span><span class="p">],</span> <span class="n">stdout</span><span class="o">=</span><span class="n">PIPE</span><span class="p">)</span><span class="o">.</span><span class="n">communicate</span><span class="p">()[</span><span class="mi">0</span><span class="p">]</span><span class="o">.</span><span class="n">decode</span><span class="p">(</span><span class="s">&quot;utf-8&quot;</span><span class="p">)</span><span class="o">.</span><span class="n">strip</span><span class="p">()</span></td>
      </tr>
      <tr>
        <td id="L41" class="blob-num js-line-number" data-line-number="41"></td>
        <td id="LC41" class="blob-code js-file-line">	<span class="k">if</span> <span class="n">remote_name</span><span class="p">:</span></td>
      </tr>
      <tr>
        <td id="L42" class="blob-num js-line-number" data-line-number="42"></td>
        <td id="LC42" class="blob-code js-file-line">		<span class="n">merge_name</span> <span class="o">=</span> <span class="n">Popen</span><span class="p">([</span><span class="s">&#39;git&#39;</span><span class="p">,</span><span class="s">&#39;config&#39;</span><span class="p">,</span><span class="s">&#39;branch.</span><span class="si">%s</span><span class="s">.merge&#39;</span> <span class="o">%</span> <span class="n">branch</span><span class="p">],</span> <span class="n">stdout</span><span class="o">=</span><span class="n">PIPE</span><span class="p">)</span><span class="o">.</span><span class="n">communicate</span><span class="p">()[</span><span class="mi">0</span><span class="p">]</span><span class="o">.</span><span class="n">decode</span><span class="p">(</span><span class="s">&quot;utf-8&quot;</span><span class="p">)</span><span class="o">.</span><span class="n">strip</span><span class="p">()</span></td>
      </tr>
      <tr>
        <td id="L43" class="blob-num js-line-number" data-line-number="43"></td>
        <td id="LC43" class="blob-code js-file-line">		<span class="k">if</span> <span class="n">remote_name</span> <span class="o">==</span> <span class="s">&#39;.&#39;</span><span class="p">:</span> <span class="c"># local</span></td>
      </tr>
      <tr>
        <td id="L44" class="blob-num js-line-number" data-line-number="44"></td>
        <td id="LC44" class="blob-code js-file-line">			<span class="n">remote_ref</span> <span class="o">=</span> <span class="n">merge_name</span></td>
      </tr>
      <tr>
        <td id="L45" class="blob-num js-line-number" data-line-number="45"></td>
        <td id="LC45" class="blob-code js-file-line">		<span class="k">else</span><span class="p">:</span></td>
      </tr>
      <tr>
        <td id="L46" class="blob-num js-line-number" data-line-number="46"></td>
        <td id="LC46" class="blob-code js-file-line">			<span class="n">remote_ref</span> <span class="o">=</span> <span class="s">&#39;refs/remotes/</span><span class="si">%s</span><span class="s">/</span><span class="si">%s</span><span class="s">&#39;</span> <span class="o">%</span> <span class="p">(</span><span class="n">remote_name</span><span class="p">,</span> <span class="n">merge_name</span><span class="p">[</span><span class="mi">11</span><span class="p">:])</span></td>
      </tr>
      <tr>
        <td id="L47" class="blob-num js-line-number" data-line-number="47"></td>
        <td id="LC47" class="blob-code js-file-line">		<span class="n">revgit</span> <span class="o">=</span> <span class="n">Popen</span><span class="p">([</span><span class="s">&#39;git&#39;</span><span class="p">,</span> <span class="s">&#39;rev-list&#39;</span><span class="p">,</span> <span class="s">&#39;--left-right&#39;</span><span class="p">,</span> <span class="s">&#39;</span><span class="si">%s</span><span class="s">...HEAD&#39;</span> <span class="o">%</span> <span class="n">remote_ref</span><span class="p">],</span><span class="n">stdout</span><span class="o">=</span><span class="n">PIPE</span><span class="p">,</span> <span class="n">stderr</span><span class="o">=</span><span class="n">PIPE</span><span class="p">)</span></td>
      </tr>
      <tr>
        <td id="L48" class="blob-num js-line-number" data-line-number="48"></td>
        <td id="LC48" class="blob-code js-file-line">		<span class="n">revlist</span> <span class="o">=</span> <span class="n">revgit</span><span class="o">.</span><span class="n">communicate</span><span class="p">()[</span><span class="mi">0</span><span class="p">]</span></td>
      </tr>
      <tr>
        <td id="L49" class="blob-num js-line-number" data-line-number="49"></td>
        <td id="LC49" class="blob-code js-file-line">		<span class="k">if</span> <span class="n">revgit</span><span class="o">.</span><span class="n">poll</span><span class="p">():</span> <span class="c"># fallback to local</span></td>
      </tr>
      <tr>
        <td id="L50" class="blob-num js-line-number" data-line-number="50"></td>
        <td id="LC50" class="blob-code js-file-line">			<span class="n">revlist</span> <span class="o">=</span> <span class="n">Popen</span><span class="p">([</span><span class="s">&#39;git&#39;</span><span class="p">,</span> <span class="s">&#39;rev-list&#39;</span><span class="p">,</span> <span class="s">&#39;--left-right&#39;</span><span class="p">,</span> <span class="s">&#39;</span><span class="si">%s</span><span class="s">...HEAD&#39;</span> <span class="o">%</span> <span class="n">merge_name</span><span class="p">],</span><span class="n">stdout</span><span class="o">=</span><span class="n">PIPE</span><span class="p">,</span> <span class="n">stderr</span><span class="o">=</span><span class="n">PIPE</span><span class="p">)</span><span class="o">.</span><span class="n">communicate</span><span class="p">()[</span><span class="mi">0</span><span class="p">]</span></td>
      </tr>
      <tr>
        <td id="L51" class="blob-num js-line-number" data-line-number="51"></td>
        <td id="LC51" class="blob-code js-file-line">		<span class="n">behead</span> <span class="o">=</span> <span class="n">revlist</span><span class="o">.</span><span class="n">decode</span><span class="p">(</span><span class="s">&quot;utf-8&quot;</span><span class="p">)</span><span class="o">.</span><span class="n">splitlines</span><span class="p">()</span></td>
      </tr>
      <tr>
        <td id="L52" class="blob-num js-line-number" data-line-number="52"></td>
        <td id="LC52" class="blob-code js-file-line">		<span class="n">ahead</span> <span class="o">=</span> <span class="nb">len</span><span class="p">([</span><span class="n">x</span> <span class="k">for</span> <span class="n">x</span> <span class="ow">in</span> <span class="n">behead</span> <span class="k">if</span> <span class="n">x</span><span class="p">[</span><span class="mi">0</span><span class="p">]</span><span class="o">==</span><span class="s">&#39;&gt;&#39;</span><span class="p">])</span></td>
      </tr>
      <tr>
        <td id="L53" class="blob-num js-line-number" data-line-number="53"></td>
        <td id="LC53" class="blob-code js-file-line">		<span class="n">behind</span> <span class="o">=</span> <span class="nb">len</span><span class="p">(</span><span class="n">behead</span><span class="p">)</span> <span class="o">-</span> <span class="n">ahead</span></td>
      </tr>
      <tr>
        <td id="L54" class="blob-num js-line-number" data-line-number="54"></td>
        <td id="LC54" class="blob-code js-file-line">
</td>
      </tr>
      <tr>
        <td id="L55" class="blob-num js-line-number" data-line-number="55"></td>
        <td id="LC55" class="blob-code js-file-line"><span class="n">out</span> <span class="o">=</span> <span class="s">&#39;</span><span class="se">\n</span><span class="s">&#39;</span><span class="o">.</span><span class="n">join</span><span class="p">([</span></td>
      </tr>
      <tr>
        <td id="L56" class="blob-num js-line-number" data-line-number="56"></td>
        <td id="LC56" class="blob-code js-file-line">	<span class="n">branch</span><span class="p">,</span></td>
      </tr>
      <tr>
        <td id="L57" class="blob-num js-line-number" data-line-number="57"></td>
        <td id="LC57" class="blob-code js-file-line">	<span class="nb">str</span><span class="p">(</span><span class="n">ahead</span><span class="p">),</span></td>
      </tr>
      <tr>
        <td id="L58" class="blob-num js-line-number" data-line-number="58"></td>
        <td id="LC58" class="blob-code js-file-line">	<span class="nb">str</span><span class="p">(</span><span class="n">behind</span><span class="p">),</span></td>
      </tr>
      <tr>
        <td id="L59" class="blob-num js-line-number" data-line-number="59"></td>
        <td id="LC59" class="blob-code js-file-line">	<span class="n">staged</span><span class="p">,</span></td>
      </tr>
      <tr>
        <td id="L60" class="blob-num js-line-number" data-line-number="60"></td>
        <td id="LC60" class="blob-code js-file-line">	<span class="n">conflicts</span><span class="p">,</span></td>
      </tr>
      <tr>
        <td id="L61" class="blob-num js-line-number" data-line-number="61"></td>
        <td id="LC61" class="blob-code js-file-line">	<span class="n">changed</span><span class="p">,</span></td>
      </tr>
      <tr>
        <td id="L62" class="blob-num js-line-number" data-line-number="62"></td>
        <td id="LC62" class="blob-code js-file-line">	<span class="n">untracked</span><span class="p">,</span></td>
      </tr>
      <tr>
        <td id="L63" class="blob-num js-line-number" data-line-number="63"></td>
        <td id="LC63" class="blob-code js-file-line">	<span class="p">])</span></td>
      </tr>
      <tr>
        <td id="L64" class="blob-num js-line-number" data-line-number="64"></td>
        <td id="LC64" class="blob-code js-file-line"><span class="k">print</span><span class="p">(</span><span class="n">out</span><span class="p">)</span></td>
      </tr>
      <tr>
        <td id="L65" class="blob-num js-line-number" data-line-number="65"></td>
        <td id="LC65" class="blob-code js-file-line">
</td>
      </tr>
</table>

  </div>

  </div>
</div>

<a href="#jump-to-line" rel="facebox[.linejump]" data-hotkey="l" style="display:none">Jump to Line</a>
<div id="jump-to-line" style="display:none">
  <form accept-charset="UTF-8" class="js-jump-to-line-form">
    <input class="linejump-input js-jump-to-line-field" type="text" placeholder="Jump to line&hellip;" autofocus>
    <button type="submit" class="button">Go</button>
  </form>
</div>

        </div>

      </div><!-- /.repo-container -->
      <div class="modal-backdrop"></div>
    </div><!-- /.container -->
  </div><!-- /.site -->


    </div><!-- /.wrapper -->

      <div class="container">
  <div class="site-footer" role="contentinfo">
    <ul class="site-footer-links right">
      <li><a href="https://status.github.com/">Status</a></li>
      <li><a href="https://developer.github.com">API</a></li>
      <li><a href="http://training.github.com">Training</a></li>
      <li><a href="http://shop.github.com">Shop</a></li>
      <li><a href="/blog">Blog</a></li>
      <li><a href="/about">About</a></li>

    </ul>

    <a href="/" aria-label="Homepage">
      <span class="mega-octicon octicon-mark-github" title="GitHub"></span>
    </a>

    <ul class="site-footer-links">
      <li>&copy; 2014 <span title="0.02425s from github-fe123-cp1-prd.iad.github.net">GitHub</span>, Inc.</li>
        <li><a href="/site/terms">Terms</a></li>
        <li><a href="/site/privacy">Privacy</a></li>
        <li><a href="/security">Security</a></li>
        <li><a href="/contact">Contact</a></li>
    </ul>
  </div><!-- /.site-footer -->
</div><!-- /.container -->


    <div class="fullscreen-overlay js-fullscreen-overlay" id="fullscreen_overlay">
  <div class="fullscreen-container js-suggester-container">
    <div class="textarea-wrap">
      <textarea name="fullscreen-contents" id="fullscreen-contents" class="fullscreen-contents js-fullscreen-contents js-suggester-field" placeholder=""></textarea>
    </div>
  </div>
  <div class="fullscreen-sidebar">
    <a href="#" class="exit-fullscreen js-exit-fullscreen tooltipped tooltipped-w" aria-label="Exit Zen Mode">
      <span class="mega-octicon octicon-screen-normal"></span>
    </a>
    <a href="#" class="theme-switcher js-theme-switcher tooltipped tooltipped-w"
      aria-label="Switch themes">
      <span class="octicon octicon-color-mode"></span>
    </a>
  </div>
</div>



    <div id="ajax-error-message" class="flash flash-error">
      <span class="octicon octicon-alert"></span>
      <a href="#" class="octicon octicon-x flash-close js-ajax-error-dismiss" aria-label="Dismiss error"></a>
      Something went wrong with that request. Please try again.
    </div>


      <script crossorigin="anonymous" src="https://assets-cdn.github.com/assets/frameworks-c0a33613f35470201fd7bf6189178c2d59468ef8460613d41682e3dd4d1677a0.js" type="text/javascript"></script>
      <script async="async" crossorigin="anonymous" src="https://assets-cdn.github.com/assets/github-7a547e19aa0d05db3ce66172529526f3ce4a384332fa212dd368aaa2ab02e79e.js" type="text/javascript"></script>
      
      
  </body>
</html>

