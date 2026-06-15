# Docker

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (Engine 20.10+ / Desktop 4.0+)
- `movies.db` placed at `db/movies.db` (see the main README for download instructions)

No Ruby toolchain is required on the host.

---

## Plain Docker

**Build the image:**

```bash
docker build -t movies-api .
```

**Run the container:**

```bash
docker run --rm -p 4000:4000 \
  -v "$(pwd)/db/movies.db:/app/db/movies.db" \
  movies-api
```

The `-v` flag bind-mounts `movies.db` from your host into the container so that any writes (migrations, etc.) are persisted back to the file on disk and survive container restarts.

---

## Docker Compose

```bash
docker compose up --build
```

To run in the background:

```bash
docker compose up --build -d
docker compose down    # to stop and remove the container
```

---

## Smoke test

Once the container is running, hit any endpoint from the API reference:

```bash
curl "http://localhost:4000/titles?year=2020"
```

Expected response shape:

```json
{
  "total_pages": 7,
  "page": 1,
  "total_result": 346,
  "result_count": 50,
  "titles": [ ... ]
}
```

Other examples:

```bash
curl "http://localhost:4000/titles?genre=Drama&rating=8.0"
curl "http://localhost:4000/titles/tt1375666"
curl "http://localhost:4000/directors/nm0634240"
```
