[1mdiff --git a/Gemfile.lock b/Gemfile.lock[m
[1mindex 6667b586c..a29d9b538 100644[m
[1m--- a/Gemfile.lock[m
[1m+++ b/Gemfile.lock[m
[36m@@ -1,9 +1,9 @@[m
 GIT[m
   remote: https://github.com/leshill/resque_spec.git[m
[31m-  revision: 316a5ba075f2d019854fa856c6c8e865ae2c1427[m
[32m+[m[32m  revision: ce0f46df0e34df003476496a931c4c3b6a2945f9[m
   branch: master[m
   specs:[m
[31m-    resque_spec (0.18.0)[m
[32m+[m[32m    resque_spec (0.18.1)[m
       resque (>= 1.26.0)[m
       rspec-core (>= 3.0.0)[m
       rspec-expectations (>= 3.0.0)[m
[36m@@ -13,44 +13,44 @@[m [mGEM[m
   remote: https://rubygems.org/[m
   remote: https://rails-assets.org/[m
   specs:[m
[31m-    actioncable (5.2.1)[m
[31m-      actionpack (= 5.2.1)[m
[32m+[m[32m    actioncable (5.2.2)[m
[32m+[m[32m      actionpack (= 5.2.2)[m
       nio4r (~> 2.0)[m
       websocket-driver (>= 0.6.1)[m
[31m-    actionmailer (5.2.1)[m
[31m-      actionpack (= 5.2.1)[m
[31m-      actionview (= 5.2.1)[m
[31m-      activejob (= 5.2.1)[m
[32m+[m[32m    actionmailer (5.2.2)[m
[32m+[m[32m      actionpack (= 5.2.2)[m
[32m+[m[32m      actionview (= 5.2.2)[m
[32m+[m[32m      activejob (= 5.2.2)[m
       mail (~> 2.5, >= 2.5.4)[m
       rails-dom-testing (~> 2.0)[m
[31m-    actionpack (5.2.1)[m
[31m-      actionview (= 5.2.1)[m
[31m-      activesupport (= 5.2.1)[m
[32m+[m[32m    actionpack (5.2.2)[m
[32m+[m[32m      actionview (= 5.2.2)[m
[32m+[m[32m      activesupport (= 5.2.2)[m
       rack (~> 2.0)[m
       rack-test (>= 0.6.3)[m
       rails-dom-testing (~> 2.0)[m
       rails-html-sanitizer (~> 1.0, >= 1.0.2)[m
[31m-    actionview (5.2.1)[m
[31m-      activesupport (= 5.2.1)[m
[32m+[m[32m    actionview (5.2.2)[m
[32m+[m[32m      activesupport (= 5.2.2)[m
       builder (~> 3.1)[m
       erubi (~> 1.4)[m
       rails-dom-testing (~> 2.0)[m
       rails-html-sanitizer (~> 1.0, >= 1.0.3)[m
[31m-    active_model_serializers (0.10.8)[m
[32m+[m[32m    active_model_serializers (0.10.9)[m
       actionpack (>= 4.1, < 6)[m
       activemodel (>= 4.1, < 6)[m
       case_transform (>= 0.2)[m
       jsonapi-renderer (>= 0.1.1.beta1, < 0.3)[m
[31m-    activejob (5.2.1)[m
[31m-      activesupport (= 5.2.1)[m
[32m+[m[32m    activejob (5.2.2)[m
[32m+[m[32m      activesupport (= 5.2.2)[m
       globalid (>= 0.3.6)[m
[31m-    activemodel (5.2.1)[m
[31m-      activesupport (= 5.2.1)[m
[31m-    activerecord (5.2.1)[m
[31m-      activemodel (= 5.2.1)[m
[31m-      activesupport (= 5.2.1)[m
[32m+[m[32m    activemodel (5.2.2)[m
[32m+[m[32m      activesupport (= 5.2.2)[m
[32m+[m[32m    activerecord (5.2.2)[m
[32m+[m[32m      activemodel (= 5.2.2)[m
[32m+[m[32m      activesupport (= 5.2.2)[m
       arel (>= 9.0)[m
[31m-    activerecord-import (0.27.0)[m
[32m+[m[32m    activerecord-import (1.0.1)[m
       activerecord (>= 3.2)[m
     activerecord-session_store (1.1.1)[m
       actionpack (>= 4.0)[m
[36m@@ -58,18 +58,18 @@[m [mGEM[m
       multi_json (~> 1.11, >= 1.11.2)[m
       rack (>= 1.5.2, < 3)[m
       railties (>= 4.0)[m
[31m-    activestorage (5.2.1)[m
[31m-      actionpack (= 5.2.1)[m
[31m-      activerecord (= 5.2.1)[m
[32m+[m[32m    activestorage (5.2.2)[m
[32m+[m[32m      actionpack (= 5.2.2)[m
[32m+[m[32m      activerecord (= 5.2.2)[m
       marcel (~> 0.3.1)[m
[31m-    activesupport (5.2.1)[m
[32m+[m[32m    activesupport (5.2.2)[m
       concurrent-ruby (~> 1.0, >= 1.0.2)[m
       i18n (>= 0.7, < 2)[m
       minitest (~> 5.1)[m
       tzinfo (~> 1.1)[m
     acts_as_list (0.9.17)[m
       activerecord (>= 3.0)[m
[31m-    addressable (2.5.2)[m
[32m+[m[32m    addressable (2.6.0)[m
       public_suffix (>= 2.0.2, < 4.0)[m
     angular-rails-templates (1.0.2)[m
       railties (>= 4.2, < 6)[m
[36m@@ -83,31 +83,31 @@[m [mGEM[m
       jquery-rails (>= 2.0.2)[m
     autoprefixer-rails (8.6.5)[m
       execjs[m
[31m-    aws-sdk (2.11.171)[m
[31m-      aws-sdk-resources (= 2.11.171)[m
[31m-    aws-sdk-core (2.11.171)[m
[32m+[m[32m    aws-sdk (2.11.229)[m
[32m+[m[32m      aws-sdk-resources (= 2.11.229)[m
[32m+[m[32m    aws-sdk-core (2.11.229)[m
       aws-sigv4 (~> 1.0)[m
       jmespath (~> 1.0)[m
[31m-    aws-sdk-resources (2.11.171)[m
[31m-      aws-sdk-core (= 2.11.171)[m
[32m+[m[32m    aws-sdk-resources (2.11.229)[m
[32m+[m[32m      aws-sdk-core (= 2.11.229)[m
     aws-sigv4 (1.0.3)[m
     bcrypt (3.1.12)[m
[31m-    better_errors (2.5.0)[m
[32m+[m[32m    better_errors (2.5.1)[m
       coderay (>= 1.0.0)[m
       erubi (>= 1.0.0)[m
       rack (>= 0.9.0)[m
     binding_of_caller (0.8.0)[m
       debug_inspector (>= 0.0.1)[m
[31m-    bootsnap (1.3.2)[m
[32m+[m[32m    bootsnap (1.4.1)[m
       msgpack (~> 1.0)[m
[31m-    bson (4.3.0)[m
[32m+[m[32m    bson (4.4.2)[m
     builder (3.2.3)[m
     bullet (5.9.0)[m
       activesupport (>= 3.0.0)[m
       uniform_notifier (~> 1.11)[m
[31m-    byebug (10.0.2)[m
[32m+[m[32m    byebug (11.0.0)[m
     cancancan (2.3.0)[m
[31m-    capybara (3.11.0)[m
[32m+[m[32m    capybara (3.14.0)[m
       addressable[m
       mini_mime (>= 0.1.3)[m
       nokogiri (~> 1.8)[m
[36m@@ -118,7 +118,7 @@[m [mGEM[m
     capybara-select2 (1.0.1)[m
       capybara[m
       rspec[m
[31m-    carrierwave (1.2.3)[m
[32m+[m[32m    carrierwave (1.3.1)[m
       activemodel (>= 4.0.0)[m
       activesupport (>= 4.0.0)[m
       mime-types (>= 1.16)[m
[36m@@ -135,7 +135,7 @@[m [mGEM[m
       coffee-script-source[m
       execjs[m
     coffee-script-source (1.12.2)[m
[31m-    concurrent-ruby (1.1.3)[m
[32m+[m[32m    concurrent-ruby (1.1.4)[m
     crack (0.4.3)[m
       safe_yaml (~> 1.0.0)[m
     crass (1.0.4)[m
[36m@@ -153,30 +153,31 @@[m [mGEM[m
     declarative-option (0.1.0)[m
     diff-lcs (1.3)[m
     docile (1.1.5)[m
[31m-    dotenv (2.5.0)[m
[31m-    dotenv-rails (2.5.0)[m
[31m-      dotenv (= 2.5.0)[m
[31m-      railties (>= 3.2, < 6.0)[m
[31m-    dry-configurable (0.7.0)[m
[32m+[m[32m    dotenv (2.7.1)[m
[32m+[m[32m    dotenv-rails (2.7.1)[m
[32m+[m[32m      dotenv (= 2.7.1)[m
[32m+[m[32m      railties (>= 3.2, < 6.1)[m
[32m+[m[32m    dry-configurable (0.8.2)[m
       concurrent-ruby (~> 1.0)[m
[31m-    dry-container (0.6.0)[m
[32m+[m[32m      dry-core (~> 0.4, >= 0.4.7)[m
[32m+[m[32m    dry-container (0.7.0)[m
       concurrent-ruby (~> 1.0)[m
       dry-configurable (~> 0.1, >= 0.1.3)[m
     dry-core (0.4.7)[m
       concurrent-ruby (~> 1.0)[m
     dry-equalizer (0.2.1)[m
     dry-inflector (0.1.2)[m
[31m-    dry-logic (0.4.2)[m
[32m+[m[32m    dry-logic (0.5.0)[m
       dry-container (~> 0.2, >= 0.2.6)[m
       dry-core (~> 0.2)[m
       dry-equalizer (~> 0.2)[m
[31m-    dry-types (0.13.2)[m
[32m+[m[32m    dry-types (0.14.0)[m
       concurrent-ruby (~> 1.0)[m
       dry-container (~> 0.3)[m
       dry-core (~> 0.4, >= 0.4.4)[m
       dry-equalizer (~> 0.2)[m
       dry-inflector (~> 0.1, >= 0.1.2)[m
[31m-      dry-logic (~> 0.4, >= 0.4.2)[m
[32m+[m[32m      dry-logic (~> 0.5, >= 0.5)[m
     dry-validation (0.10.7)[m
       concurrent-ruby (~> 1.0)[m
       dry-configurable (~> 0.1, >= 0.1.3)[m
[36m@@ -184,9 +185,9 @@[m [mGEM[m
       dry-equalizer (~> 0.2)[m
       dry-logic (~> 0.4, >= 0.4.0)[m
       dry-types (~> 0.9, >= 0.9.0)[m
[31m-    erubi (1.7.1)[m
[32m+[m[32m    erubi (1.8.0)[m
     erubis (2.7.0)[m
[31m-    et-orbi (1.1.6)[m
[32m+[m[32m    et-orbi (1.1.7)[m
       tzinfo[m
     excon (0.62.0)[m
     execjs (2.7.0)[m
[36m@@ -195,12 +196,12 @@[m [mGEM[m
     factory_bot_rails (4.11.1)[m
       factory_bot (~> 4.11.1)[m
       railties (>= 3.0.0)[m
[31m-    faker (1.9.1)[m
[32m+[m[32m    faker (1.9.3)[m
       i18n (>= 0.7)[m
     faraday (0.15.4)[m
       multipart-post (>= 1.2, < 3)[m
     fast_blank (1.0.0)[m
[31m-    ffi (1.9.25)[m
[32m+[m[32m    ffi (1.10.0)[m
     ffi-compiler (1.0.1)[m
       ffi (>= 1.0.0)[m
       rake[m
[36m@@ -225,20 +226,20 @@[m [mGEM[m
     foreman (0.85.0)[m
       thor (~> 0.19.1)[m
     formatador (0.2.5)[m
[31m-    fugit (1.1.6)[m
[31m-      et-orbi (~> 1.1, >= 1.1.6)[m
[32m+[m[32m    fugit (1.1.8)[m
[32m+[m[32m      et-orbi (~> 1.1, >= 1.1.7)[m
       raabro (~> 1.1)[m
[31m-    globalid (0.4.1)[m
[32m+[m[32m    globalid (0.4.2)[m
       activesupport (>= 4.2.0)[m
[31m-    google-api-client (0.25.0)[m
[32m+[m[32m    google-api-client (0.28.4)[m
       addressable (~> 2.5, >= 2.5.1)[m
[31m-      googleauth (>= 0.5, < 0.7.0)[m
[32m+[m[32m      googleauth (>= 0.5, < 0.10.0)[m
       httpclient (>= 2.8.1, < 3.0)[m
       mime-types (~> 3.0)[m
       representable (~> 3.0)[m
       retriable (>= 2.0, < 4.0)[m
       signet (~> 0.10)[m
[31m-    googleauth (0.6.7)[m
[32m+[m[32m    googleauth (0.8.0)[m
       faraday (~> 0.12)[m
       jwt (>= 1.4, < 3.0)[m
       memoist (~> 0.16)[m
[36m@@ -254,7 +255,7 @@[m [mGEM[m
       haml (>= 4.0.6, < 6.0)[m
       html2haml (>= 1.0.1)[m
       railties (>= 4.0.1)[m
[31m-    hashdiff (0.3.7)[m
[32m+[m[32m    hashdiff (0.3.8)[m
     hashie (3.6.0)[m
     hodel_3000_compliant_logger (0.1.1)[m
     html2haml (2.2.0)[m
[36m@@ -262,18 +263,18 @@[m [mGEM[m
       haml (>= 4.0, < 6)[m
       nokogiri (>= 1.6.0)[m
       ruby_parser (~> 3.5)[m
[31m-    httparty (0.16.3)[m
[32m+[m[32m    httparty (0.16.4)[m
       mime-types (~> 3.0)[m
       multi_xml (>= 0.5.2)[m
     httpclient (2.8.3)[m
[31m-    i18n (1.1.1)[m
[32m+[m[32m    i18n (1.5.3)[m
       concurrent-ruby (~> 1.0)[m
     ims-lti (1.1.13)[m
       builder[m
       oauth (>= 0.4.5, < 0.6)[m
     io-like (0.3.0)[m
     ipaddress (0.8.3)[m
[31m-    jaro_winkler (1.5.1)[m
[32m+[m[32m    jaro_winkler (1.5.2)[m
     jasmine-core (2.99.2)[m
     jasmine-rails (0.14.8)[m
       jasmine-core (>= 1.3, < 3.0)[m
[36m@@ -292,7 +293,7 @@[m [mGEM[m
       rails-dom-testing (>= 1, < 3)[m
       railties (>= 4.2.0)[m
       thor (>= 0.14, < 2.0)[m
[31m-    json (2.1.0)[m
[32m+[m[32m    json (2.2.0)[m
     jsonapi-renderer (0.2.0)[m
     jwt (2.1.0)[m
     launchy (2.4.3)[m
[36m@@ -315,28 +316,28 @@[m [mGEM[m
     mime-types (3.2.2)[m
       mime-types-data (~> 3.2015)[m
     mime-types-data (3.2018.0812)[m
[31m-    mimemagic (0.3.2)[m
[31m-    mini_magick (4.9.2)[m
[32m+[m[32m    mimemagic (0.3.3)[m
[32m+[m[32m    mini_magick (4.9.3)[m
     mini_mime (1.0.1)[m
[31m-    mini_portile2 (2.3.0)[m
[32m+[m[32m    mini_portile2 (2.4.0)[m
     minitest (5.11.3)[m
[31m-    mongo (2.6.2)[m
[31m-      bson (>= 4.3.0, < 5.0.0)[m
[32m+[m[32m    mongo (2.7.1)[m
[32m+[m[32m      bson (>= 4.4.2, < 5.0.0)[m
     mongoid (6.0.3)[m
       activemodel (~> 5.0)[m
       mongo (~> 2.3)[m
     mono_logger (1.1.0)[m
[31m-    msgpack (1.2.4)[m
[32m+[m[32m    msgpack (1.2.6)[m
     multi_json (1.13.1)[m
     multi_xml (0.6.0)[m
     multipart-post (2.0.0)[m
     mustermann (1.0.3)[m
     namae (1.0.1)[m
[31m-    newrelic_rpm (5.5.0.348)[m
[32m+[m[32m    newrelic_rpm (6.1.0.352)[m
     ng-rails-csrf (0.1.0)[m
     nio4r (2.3.1)[m
[31m-    nokogiri (1.8.5)[m
[31m-      mini_portile2 (~> 2.3.0)[m
[32m+[m[32m    nokogiri (1.10.1)[m
[32m+[m[32m      mini_portile2 (~> 2.4.0)[m
     nokogumbo (2.0.1)[m
       nokogiri (~> 1.8, >= 1.8.4)[m
     oauth (0.5.4)[m
[36m@@ -349,7 +350,7 @@[m [mGEM[m
     oink (0.10.1)[m
       activerecord[m
       hodel_3000_compliant_logger[m
[31m-    oj (3.7.1)[m
[32m+[m[32m    oj (3.7.9)[m
     omniauth (1.9.0)[m
       hashie (>= 3.4.6, < 3.7.0)[m
       rack (>= 1.6.2, < 3)[m
[36m@@ -378,11 +379,11 @@[m [mGEM[m
       activerecord (>= 4.2, < 5.3)[m
       paper_trail-association_tracking (< 2)[m
       request_store (~> 1.1)[m
[31m-    paper_trail-association_tracking (1.0.0)[m
[31m-    parallel (1.12.1)[m
[31m-    parser (2.5.3.0)[m
[32m+[m[32m    paper_trail-association_tracking (1.1.1)[m
[32m+[m[32m    parallel (1.14.0)[m
[32m+[m[32m    parser (2.6.0.0)[m
       ast (~> 2.4.0)[m
[31m-    pg (1.1.3)[m
[32m+[m[32m    pg (1.1.4)[m
     phantomjs (2.1.1.0)[m
     porch (0.3.1)[m
       dry-validation (~> 0.10.4)[m
[36m@@ -390,31 +391,32 @@[m [mGEM[m
     pry (0.12.2)[m
       coderay (~> 1.1.0)[m
       method_source (~> 0.9.0)[m
[31m-    pry-byebug (3.6.0)[m
[31m-      byebug (~> 10.0)[m
[32m+[m[32m    pry-byebug (3.7.0)[m
[32m+[m[32m      byebug (~> 11.0)[m
       pry (~> 0.10)[m
[32m+[m[32m    psych (3.1.0)[m
     public_suffix (3.0.3)[m
     puma (3.12.0)[m
     raabro (1.1.6)[m
     rack (2.0.6)[m
[31m-    rack-mini-profiler (1.0.0)[m
[32m+[m[32m    rack-mini-profiler (1.0.2)[m
       rack (>= 1.2.0)[m
[31m-    rack-protection (2.0.4)[m
[32m+[m[32m    rack-protection (2.0.5)[m
       rack[m
     rack-test (1.1.0)[m
       rack (>= 1.0, < 3)[m
[31m-    rails (5.2.1)[m
[31m-      actioncable (= 5.2.1)[m
[31m-      actionmailer (= 5.2.1)[m
[31m-      actionpack (= 5.2.1)[m
[31m-      actionview (= 5.2.1)[m
[31m-      activejob (= 5.2.1)[m
[31m-      activemodel (= 5.2.1)[m
[31m-      activerecord (= 5.2.1)[m
[31m-      activestorage (= 5.2.1)[m
[31m-      activesupport (= 5.2.1)[m
[32m+[m[32m    rails (5.2.2)[m
[32m+[m[32m      actioncable (= 5.2.2)[m
[32m+[m[32m      actionmailer (= 5.2.2)[m
[32m+[m[32m      actionpack (= 5.2.2)[m
[32m+[m[32m      actionview (= 5.2.2)[m
[32m+[m[32m      activejob (= 5.2.2)[m
[32m+[m[32m      activemodel (= 5.2.2)[m
[32m+[m[32m      activerecord (= 5.2.2)[m
[32m+[m[32m      activestorage (= 5.2.2)[m
[32m+[m[32m      activesupport (= 5.2.2)[m
       bundler (>= 1.3.0)[m
[31m-      railties (= 5.2.1)[m
[32m+[m[32m      railties (= 5.2.2)[m
       sprockets-rails (>= 2.0.0)[m
     rails-assets-angular (1.3.20)[m
     rails-assets-angular-animate (1.3.20)[m
[36m@@ -432,10 +434,10 @@[m [mGEM[m
     rails-assets-ngDraggable (0.1.11)[m
       rails-assets-angular[m
     rails-assets-rollbar.js (2.5.0)[m
[31m-    rails-controller-testing (1.0.2)[m
[31m-      actionpack (~> 5.x, >= 5.0.1)[m
[31m-      actionview (~> 5.x, >= 5.0.1)[m
[31m-      activesupport (~> 5.x)[m
[32m+[m[32m    rails-controller-testing (1.0.4)[m
[32m+[m[32m      actionpack (>= 5.0.1.x)[m
[32m+[m[32m      actionview (>= 5.0.1.x)[m
[32m+[m[32m      activesupport (>= 5.0.1.x)[m
     rails-dom-testing (2.0.3)[m
       activesupport (>= 4.2.0)[m
       nokogiri (>= 1.6)[m
[36m@@ -443,28 +445,28 @@[m [mGEM[m
       loofah (~> 2.2, >= 2.2.2)[m
     rails_autolink (1.1.6)[m
       rails (> 3.1)[m
[31m-    railties (5.2.1)[m
[31m-      actionpack (= 5.2.1)[m
[31m-      activesupport (= 5.2.1)[m
[32m+[m[32m    railties (5.2.2)[m
[32m+[m[32m      actionpack (= 5.2.2)[m
[32m+[m[32m      activesupport (= 5.2.2)[m
       method_source[m
       rake (>= 0.8.7)[m
       thor (>= 0.19.0, < 2.0)[m
     rainbow (3.0.0)[m
[31m-    rake (12.3.1)[m
[32m+[m[32m    rake (12.3.2)[m
     rake-hooks (1.2.3)[m
       rake[m
[31m-    ransack (2.1.0)[m
[32m+[m[32m    ransack (2.1.1)[m
       actionpack (>= 5.0)[m
       activerecord (>= 5.0)[m
       activesupport (>= 5.0)[m
       i18n[m
     rb-fsevent (0.10.3)[m
[31m-    rb-inotify (0.9.10)[m
[31m-      ffi (>= 0.5.0, < 2)[m
[32m+[m[32m    rb-inotify (0.10.0)[m
[32m+[m[32m      ffi (~> 1.0)[m
     rdiscount (2.2.0.1)[m
[31m-    recaptcha (4.13.0)[m
[32m+[m[32m    recaptcha (4.13.1)[m
       json[m
[31m-    redis (4.0.3)[m
[32m+[m[32m    redis (4.1.0)[m
     redis-namespace (1.6.0)[m
       redis (>= 3.0.4)[m
     regexp_parser (1.3.0)[m
[36m@@ -474,9 +476,9 @@[m [mGEM[m
       uber (< 0.2.0)[m
     request_store (1.4.1)[m
       rack (>= 1.4)[m
[31m-    responders (2.4.0)[m
[31m-      actionpack (>= 4.2.0, < 5.3)[m
[31m-      railties (>= 4.2.0, < 5.3)[m
[32m+[m[32m    responders (2.4.1)[m
[32m+[m[32m      actionpack (>= 4.2.0, < 6.0)[m
[32m+[m[32m      railties (>= 4.2.0, < 6.0)[m
     resque (1.27.4)[m
       mono_logger (~> 1.0)[m
       multi_json (~> 1.0)[m
[36m@@ -494,7 +496,7 @@[m [mGEM[m
     resque-throttler (0.1.5)[m
       resque (~> 1.25)[m
     retriable (3.1.2)[m
[31m-    rollbar (2.18.0)[m
[32m+[m[32m    rollbar (2.19.2)[m
       multi_json[m
     rspec (3.8.0)[m
       rspec-core (~> 3.8.0)[m
[36m@@ -511,7 +513,7 @@[m [mGEM[m
     rspec-mocks (3.8.0)[m
       diff-lcs (>= 1.2.0, < 2.0)[m
       rspec-support (~> 3.8.0)[m
[31m-    rspec-rails (3.8.1)[m
[32m+[m[32m    rspec-rails (3.8.2)[m
       actionpack (>= 3.0)[m
       activesupport (>= 3.0)[m
       railties (>= 3.0)[m
[36m@@ -520,18 +522,19 @@[m [mGEM[m
       rspec-mocks (~> 3.8.0)[m
       rspec-support (~> 3.8.0)[m
     rspec-support (3.8.0)[m
[31m-    rubocop (0.60.0)[m
[32m+[m[32m    rubocop (0.65.0)[m
       jaro_winkler (~> 1.5.1)[m
       parallel (~> 1.10)[m
       parser (>= 2.5, != 2.5.1.1)[m
       powerpack (~> 0.1)[m
[32m+[m[32m      psych (>= 3.1.0)[m
       rainbow (>= 2.2.2, < 4.0)[m
       ruby-progressbar (~> 1.7)[m
       unicode-display_width (~> 1.4.0)[m
     ruby-progressbar (1.10.0)[m
     ruby-saml (1.9.0)[m
       nokogiri (>= 1.5.10)[m
[31m-    ruby_parser (3.11.0)[m
[32m+[m[32m    ruby_parser (3.12.0)[m
       sexp_processor (~> 4.9)[m
     rubystats (0.3.0)[m
     rufus-scheduler (3.5.2)[m
[36m@@ -541,13 +544,13 @@[m [mGEM[m
       jquery-fileupload-rails (~> 0.4.1)[m
       rails (>= 3.1)[m
       sass-rails (>= 3.1)[m
[31m-    safe_yaml (1.0.4)[m
[32m+[m[32m    safe_yaml (1.0.5)[m
     sampler (0.0.5)[m
     sanitize (5.0.0)[m
       crass (~> 1.0.2)[m
       nokogiri (>= 1.8.0)[m
       nokogumbo (~> 2.0)[m
[31m-    sass (3.7.2)[m
[32m+[m[32m    sass (3.7.3)[m
       sass-listen (~> 4.0.0)[m
     sass-listen (4.0.0)[m
       rb-fsevent (~> 0.9, >= 0.9.4)[m
[36m@@ -558,10 +561,10 @@[m [mGEM[m
       sprockets (>= 2.8, < 4.0)[m
       sprockets-rails (>= 2.0, < 4.0)[m
       tilt (>= 1.1, < 3)[m
[31m-    sassc (2.0.0)[m
[31m-      ffi (~> 1.9.6)[m
[32m+[m[32m    sassc (2.0.1)[m
[32m+[m[32m      ffi (~> 1.9)[m
       rake[m
[31m-    sassc-rails (2.0.0)[m
[32m+[m[32m    sassc-rails (2.1.0)[m
       railties (>= 4.0.0)[m
       sassc (>= 2.0)[m
       sprockets (> 3.0)[m
[36m@@ -577,7 +580,7 @@[m [mGEM[m
       faraday (~> 0.9)[m
       jwt (>= 1.5, < 3.0)[m
       multi_json (~> 1.10)[m
[31m-    simple_form (4.0.1)[m
[32m+[m[32m    simple_form (4.1.0)[m
       actionpack (>= 5.0)[m
       activemodel (>= 5.0)[m
     simplecov (0.13.0)[m
[36m@@ -585,12 +588,12 @@[m [mGEM[m
       json (>= 1.8, < 3)[m
       simplecov-html (~> 0.10.0)[m
     simplecov-html (0.10.2)[m
[31m-    sinatra (2.0.4)[m
[32m+[m[32m    sinatra (2.0.5)[m
       mustermann (~> 1.0)[m
       rack (~> 2.0)[m
[31m-      rack-protection (= 2.0.4)[m
[32m+[m[32m      rack-protection (= 2.0.5)[m
       tilt (~> 2.0)[m
[31m-    sorcery (0.12.0)[m
[32m+[m[32m    sorcery (0.13.0)[m
       bcrypt (~> 3.1)[m
       oauth (~> 0.4, >= 0.4.4)[m
       oauth2 (~> 1.0, >= 0.8.0)[m
[36m@@ -612,12 +615,12 @@[m [mGEM[m
     uglifier (3.2.0)[m
       execjs (>= 0.3.0, < 3)[m
     underscore-rails (1.8.3)[m
[31m-    unicode-display_width (1.4.0)[m
[32m+[m[32m    unicode-display_width (1.4.1)[m
     uniform_notifier (1.12.1)[m
     valid_attribute (2.0.0)[m
     vegas (0.1.11)[m
       rack (>= 1.0.0)[m
[31m-    webmock (3.4.2)[m
[32m+[m[32m    webmock (3.5.1)[m
       addressable (>= 2.3.6)[m
       crack (>= 0.3.2)[m
       hashdiff[m
[36m@@ -626,7 +629,7 @@[m [mGEM[m
     websocket-extensions (0.1.3)[m
     whenever (0.10.0)[m
       chronic (>= 0.6.3)[m
[31m-    wysiwyg-rails (2.9.1)[m
[32m+[m[32m    wysiwyg-rails (2.9.3)[m
       railties (>= 3.2, < 6.0)[m
     xpath (3.2.0)[m
       nokogiri (~> 1.8)[m
[1mdiff --git a/db/schema.rb b/db/schema.rb[m
[1mindex a8d51cfbf..1663a91ea 100644[m
[1m--- a/db/schema.rb[m
[1m+++ b/db/schema.rb[m
[36m@@ -881,6 +881,7 @@[m [mActiveRecord::Schema.define(version: 2019_01_04_204001) do[m
     t.boolean "instructor_unlocked"[m
     t.datetime "created_at"[m
     t.datetime "updated_at"[m
[32m+[m[32m    t.boolean "notified"[m
     t.index ["student_id"], name: "index_unlock_states_on_student_id"[m
     t.index ["unlockable_id", "unlockable_type"], name: "index_unlock_states_on_unlockable_id_and_unlockable_type"[m
   end[m
