import { ZodError } from 'zod';

export function errorHandler(err, req, res, _next) {
  if (err instanceof ZodError) {
    return res.status(422).json({
      success: false,
      statusCode: 422,
      error: 'VALIDATION_ERROR',
      message: 'Request validation failed',
      details: err.issues.map(issue => ({
        field: issue.path.join('.'),
        message: issue.message
      })),
      requestId: req.requestId
    });
  }

  const statusCode = Number(err.statusCode) || 500;
  const safeMessage = statusCode >= 500 ? 'An unexpected server error occurred' : err.message;

  if (statusCode >= 500) {
    console.error({ requestId: req.requestId, error: err.stack || err.message });
  }

  return res.status(statusCode).json({
    success: false,
    statusCode,
    error: err.code || 'INTERNAL_SERVER_ERROR',
    message: safeMessage,
    ...(err.details ? { details: err.details } : {}),
    requestId: req.requestId
  });
}
