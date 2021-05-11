const createProxyMiddleware = require('http-proxy-middleware');module.exports = function(app) {
  app.use(
    '/papi',
    createProxyMiddleware({
      target: 'http://localhost/',
      changeOrigin: true,
    })
  );
};
