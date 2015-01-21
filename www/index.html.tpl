<!doctype html>
<html class="notie no-js">
<head>
  <meta charset="utf-8" />
  <title>Ohmage | Dashboard</title>
  <meta name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no, minimal-ui">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <link rel="shortcut icon" href="/favicon.ico?v=1.1">

  <link rel="stylesheet" href="<%= css_path %>" />
  <script src="cordova.js"></script>
  <script src="<%= js_modernizr_path %>"></script>
</head>
<body>
  <div id="loading-spinner"></div>
  <header role="banner"></header>
  <main role="main"></main>
  <footer role="contentinfo"></footer>
  <script src="<%= js_jquery_path %>"></script>
  <script src="<%= js_path %>"></script>
  <script type="text/javascript">
  $(function() {
    var myConfig = {
        environment: "<%= js_env %>",
        root_path: "<%= root_path %>",
        url: "<%= js_url %>",
        package_info: {
          app_name: "<%= app_name %>",
          bundle_id: "<%= bundle_id %>"
        }
      };
    if (typeof window.cordova !== "undefined") {
      document.addEventListener('deviceready', function() {
        // The app uses key device event listeners on mobile.
        // Only start it up on 'deviceready'.
        Ohmage.start(_.extend(myConfig, {cordova: true} ));
      });
    } else {
      Ohmage.start(_.extend(myConfig, {cordova: false} ));
    }
  });
  </script>
</body>
</html>