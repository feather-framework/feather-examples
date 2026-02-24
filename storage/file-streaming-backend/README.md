# file-streaming-backend

Minimal backend implementing the `file-streaming-openapi` contracts with local Feather storage drivers.

## Endpoints

- `PUT /upload`
  - Request: `application/octet-stream`
  - Response: `201`, JSON body `{ "receivedBytes": <int> }`
  - Header: `Transfer-Encoding: chunked`
- `GET /download`
  - Response: `200`, `application/octet-stream`
  - Header: `Transfer-Encoding: chunked`

The server stores uploaded bytes to one configured storage object key and returns that object on download.

## Dependencies

- Local package paths:
  - `../feather-storage`
  - `../feather-storage-fs`
- Runtime framework:
  - Hummingbird

## Configuration

Environment variables or `.env.development`:

- `HTTP_HOST` (default from Hummingbird)
- `HTTP_PORT` (default from Hummingbird)
- `LOG_LEVEL` (default: `info`)
- `STORAGE_PATH` (default: `./storage`)
- `STORAGE_OBJECTKEY` (default: `upload.bin`)

## Run

```bash
cd /Users/tib/vibestorage/file-streaming-backend
swift run Server
```
