function fn() {
  var env = karate.env || 'dev';

  var envConfig = karate.read('classpath:env-config.json');
  var currentEnv = envConfig[env];

   let config = {
    baseUrl: currentEnv.baseUrl,
    timeoutMs: 30000,
  }

  karate.configure('headers', { 'Accept': 'application/json' });
  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);
  karate.configure('connectTimeout', config.timeoutMs);
  karate.configure('readTimeout', config.timeoutMs);
  
  return config;
}