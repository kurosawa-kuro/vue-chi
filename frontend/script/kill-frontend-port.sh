#!/bin/bash

# Kill process running on port 5173 (Vite dev server)
lsof -ti:5173 | xargs kill -9 