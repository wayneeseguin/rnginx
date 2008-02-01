
#read the file in
#remove comment lines.
#Parse object sections out of file
#Objects should be stored as an array of hashes as to preserve order.
#example of a parsed nginx.conf file:
@config = [
  :user => "user group",
  :worker_processes => "6",
  :pid => "/var/run/nginx.pid",
  :events => [
    :worker_connections => "1024"
  ],

  :html => [
    :server_names_hash_bucket_size => 128,
    :charset => "utf-8",
    :include => "/usr/local/nginx/conf/mime.types",
    :default_type => "application/octet-stream",
    :log_format  => %q{main '$remote_addr - $remote_user [$time_local] $status ' '"$request" $body_bytes_sent "$http_referer" ' '"$http_user_agent" "$http_x_forwarded_for"'},
    :access_log => "/var/log/nginx/access.log main",
    :error_log => "/var/log/nginx/error.log debug",
    :sendfile => "on",
    :tcp_nopush => "on",
    :tcp_nodelay => "off",
    :gzip => "on",
    :gzip_http_version => "1.0",
    :gzip_comp_level => "2",
    :gzip_proxied => "any",
    :gzip_types => [
      "text/plain", 
      "text/html", 
      "text/css", 
      "application/x-javascript", 
      "text/xml", 
      "application/xml", 
      "application/xml+rss", 
      "application/xml+atom", 
      "text/javascript"
    ],

    ##  chase down the include to get the below parsed
    # include /etc/nginx/servers/*;

    :upstream => [:server => "server 127.0.0.1:1234;"],
    :server => [
      :listen => "80",
      :client_max_body_size => "50M",
      :server_name => ["domain.tld", "*.domain.tld"],
      :root =>  "/home/overnothing/current/public",
      :access_log => "/var/log/nginx.vhost.access.log main",
      :location  => 
      {
        :arguments => "~ \.(php|asp|aspx|jsp|cfm|dll)$",
        :block => [
          :deny => :all,
          :break => true
        ]
      },
      :if =>
      {
        :arguments => "-f $document_root/system/maintenance.html",
        :block => [
          :rewrite => ["^(.*)$", "/system/maintenance.html", "last"],
          :break => true
        ]
      },
      :location => {
        :arguments => "/",
        :block => [
          :proxy_set_header => "X-Real-IP $remote_addr",
          :proxy_set_header => "X-Forwarded-For $proxy_add_x_forwarded_for",
          :proxy_set_header => "Host $http_host",
          :proxy_redirect => "false",
          :proxy_max_temp_file_size => "0",

          # If the file exists as a static file serve it directly without
          # running all the other rewite tests on it
          :if => { 
            :arguments => "-f $request_filename",
            :body => [
              :break => true
            ]
          },
          :if => {
            :arguments => "-f $request_filename/index.html",
            :rewrite =>  ["(.*)", "$1/index.html", "break"]
          },
          :if => {
            :arguments => "-f $request_filename.html",
            :rewrite => ["(.*)", "$1.html", "break"]
          },
          :if => {
            :arguments => "!-f $request_filename",
            :body => 
            [
              :proxy_pass => "http://application.com",
              :break => true
            ]
          }
        ] # location / body
      }, # location /
      :error_page => "500 502 503 504 /500.html",
      :location => {
        :arguments => "/500.html",
        :body => [
          :root => "/home/application/current/public"
        ]
      } 
    ] # server body
  ] # html
] #config
