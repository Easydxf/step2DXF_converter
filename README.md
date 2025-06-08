# CAD Sheet Metal Unfolding Service

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy)

A cloud-based backend service that automatically unfolds sheet metal parts from 3D STEP files and exports them as manufacturing-ready DXF files. Built with FastAPI and FreeCAD for industrial automation.

## 🎯 Purpose

This service automates the tedious process of converting 3D sheet metal designs into flat patterns for fabrication:

- **Input**: Upload `.step` or `.stp` files (parts or assemblies)
- **Processing**: Automatically detect sheet metal parts, unfold to flat patterns
- **Output**: Download `.dxf` files ready for CNC cutting, laser cutting, or fabrication

Perfect for:
- Engineers needing quick flat patterns from 3D designs
- Fabrication shops automating quote generation
- Web platforms offering instant manufacturing estimates

## 🚀 Quick Start

### Option 1: Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/cad-sheet-metal-service.git
cd cad-sheet-metal-service

# Build and run with Docker Compose
docker-compose up --build

# Service available at http://localhost:8000
```

### Option 2: Local Development

```bash
# Install system dependencies (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install freecad-python3 python3.9 python3-pip

# Install Python dependencies
pip install -r requirements.txt

# Run the service
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

## 📡 API Usage

### Upload and Process STEP File

```bash
curl -X POST "http://localhost:8000/api/v1/process-step" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@your_part.step" \
  -F "k_factor=0.5" \
  -F "bend_radius=1.0"
```

**Response:**
```json
{
  "job_id": "uuid-job-id",
  "status": "processing",
  "message": "File uploaded successfully"
}
```

### Check Processing Status

```bash
curl "http://localhost:8000/api/v1/job/{job_id}/status"
```

**Response:**
```json
{
  "job_id": "uuid-job-id",
  "status": "completed",
  "parts_found": 3,
  "parts_processed": 3,
  "download_url": "/api/v1/job/{job_id}/download"
}
```

### Download Results

```bash
curl "http://localhost:8000/api/v1/job/{job_id}/download" -o results.zip
```

## 🛠️ Configuration

### Environment Variables

```bash
# Server Configuration
PORT=8000
HOST=0.0.0.0

# Processing Limits (Free Tier Optimized)
MAX_FILE_SIZE=10485760        # 10MB
PROCESSING_TIMEOUT=300        # 5 minutes
MAX_PARTS_PER_ASSEMBLY=20     # Complexity limit

# FreeCAD Configuration
FREECAD_PATH=/usr/bin/freecad
DEFAULT_K_FACTOR=0.5          # Bend compensation
DEFAULT_BEND_RADIUS=1.0       # Default bend radius (mm)

# Storage Configuration
TEMP_DIR=./temp
UPLOAD_DIR=./uploads
OUTPUT_DIR=./outputs
```

### File Limits

| Tier | Max File Size | Max Parts | Processing Time |
|------|---------------|-----------|-----------------|
| Free | 10MB | 20 parts | 5 minutes |
| Paid | 100MB | 100 parts | 30 minutes |

## 🏗️ Architecture

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   FastAPI   │───▶│   FreeCAD    │───▶│   DXF       │
│   Upload    │    │   Processing │    │   Export    │
└─────────────┘    └──────────────┘    └─────────────┘
```

### Core Components

- **FastAPI Backend**: Handles HTTP requests, file uploads, job management
- **FreeCAD Engine**: Processes 3D geometry, unfolds sheet metal parts
- **Async Processing**: Background job processing for large files
- **Docker Container**: Isolated, reproducible environment

## 🚀 Deployment

### Deploy to Render.com (Free Tier)

1. Fork this repository
2. Create account at [render.com](https://render.com)
3. Connect your GitHub repository
4. Deploy using `render.yaml` configuration
5. Service will be available at your Render URL

### Manual Deployment

```bash
# Build Docker image
docker build -t cad-service .

# Run container
docker run -p 8000:8000 \
  -e MAX_FILE_SIZE=10485760 \
  -v $(pwd)/uploads:/app/uploads \
  -v $(pwd)/outputs:/app/outputs \
  cad-service
```

### Production Considerations

- **Memory**: Minimum 512MB RAM (1GB+ recommended)
- **Storage**: Temporary file cleanup required
- **Monitoring**: Health checks at `/health`
- **Scaling**: Stateless design supports horizontal scaling

## 🧪 Testing

```bash
# Run all tests
pytest

# Run specific test categories
pytest tests/test_api.py           # API tests
pytest tests/test_freecad_processor.py  # FreeCAD tests
pytest tests/test_file_handling.py # File handling tests

# Run with coverage
pytest --cov=app tests/
```

### Test Files

Sample STEP files are provided in `tests/fixtures/`:
- `sample.step` - Simple sheet metal part
- `sample_assembly.step` - Assembly with multiple parts

## 📝 API Documentation

Once running, visit:
- **Interactive Docs**: http://localhost:8000/docs
- **OpenAPI Schema**: http://localhost:8000/openapi.json

## 🔧 Development

### Project Structure

```
cad-sheet-metal-service/
├── app/                    # FastAPI application
│   ├── api/               # API routes and models
│   ├── core/              # Core processing logic
│   ├── services/          # Business logic services
│   └── utils/             # Utilities and helpers
├── freecad_scripts/       # FreeCAD automation scripts
├── tests/                 # Test suite
└── docs/                  # Documentation
```

### Adding New Features

1. **API Changes**: Modify `app/api/routes.py` and `models.py`
2. **Processing Logic**: Add to `freecad_scripts/` directory
3. **Business Logic**: Extend services in `app/services/`
4. **Tests**: Add corresponding tests in `tests/` directory

## 🚨 Limitations

### Current Constraints

- **Sheet Metal Detection**: Heuristic-based, may miss complex geometries
- **Manual Intervention**: No support for ambiguous cases requiring user input
- **K-Factor Accuracy**: Uses default values, not material-specific
- **Memory Usage**: Large assemblies may exceed free tier limits

### Known Issues

- Complex bent features may not unfold correctly
- Some imported STEP files may fail sheet metal conversion
- Processing times vary significantly with file complexity

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

### Development Setup

```bash
# Install development dependencies
pip install -r requirements.txt
pip install pytest pytest-cov black isort

# Format code
black app/ freecad_scripts/ tests/
isort app/ freecad_scripts/ tests/

# Run tests
pytest --cov=app
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check `docs/` directory
- **Issues**: Open GitHub issue with detailed description
- **Troubleshooting**: See `docs/TROUBLESHOOTING.md`

## 🙏 Acknowledgments

- [FreeCAD](https://www.freecadweb.org/) - Open source CAD platform
- [FastAPI](https://fastapi.tiangolo.com/) - Modern Python web framework
- [Render.com](https://render.com/) - Cloud deployment platform

---

**Made with ❤️ for the manufacturing community**
