<?php
header("Content-Type: text/html; charset=UTF-8");

// Baca file openapi.json dan embed langsung ke JavaScript
$specPath = __DIR__ . '/openapi.json';
$specJson = file_exists($specPath) ? file_get_contents($specPath) : '{}';
$specJson = json_encode($specJson); // escape untuk JS string
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>ENDO Indonesia API Documentation - Swagger UI</title>
  <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
  <style>
    html { box-sizing: border-box; overflow: -moz-scrollbars-vertical; overflow-y: scroll; }
    *, *:before, *:after { box-sizing: inherit; }
    body { margin: 0; background: #fafafa; }
  </style>
</head>
<body>
  <div id="swagger-ui"></div>
  <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js" charset="UTF-8"></script>
  <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-standalone-preset.js" charset="UTF-8"></script>
  <script>
    window.onload = function() {
      var spec = JSON.parse(<?php echo $specJson; ?>);
      // Set server URL ke direktori tempat file ini berada
      spec.servers = [{ url: window.location.pathname.replace(/\/[^\/]*$/, ''), description: "Auto Server" }];
      window.ui = SwaggerUIBundle({
        spec: spec,
        dom_id: '#swagger-ui',
        deepLinking: true,
        presets: [
          SwaggerUIBundle.presets.apis,
          SwaggerUIStandalonePreset
        ],
        plugins: [
          SwaggerUIBundle.plugins.DownloadUrl
        ],
        layout: "StandaloneLayout"
      });
    };
  </script>
</body>
</html>
