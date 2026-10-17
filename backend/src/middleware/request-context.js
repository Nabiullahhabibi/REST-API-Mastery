import { randomUUID } from 'node:crypto';

export function requestContext(req, res, next) {
  req.requestId = randomUUID();
  res.setHeader('X-Request-Id', req.requestId);
  const started = Date.now();
  res.on('finish', () => {
    console.log(JSON.stringify({
      requestId: req.requestId,
      method: req.method,
      path: req.originalUrl,
      statusCode: res.statusCode,
      durationMs: Date.now() - started
    }));
  });
  next();
}
