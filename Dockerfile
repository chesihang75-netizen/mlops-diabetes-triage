# ---------- 基础镜像 ----------
FROM python:3.10-slim

# 设置环境变量（减少缓存、提升可读性）
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

WORKDIR /app

# ---------- 安装依赖 ----------
COPY requirements.txt .
RUN python -m pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# ---------- 拷贝项目代码 ----------
COPY . .

# ---------- 构建时自动训练模型 ----------
# 在镜像构建阶段运行你的训练脚本（生成 model.joblib / scaler.joblib）
RUN python src/train_model.py

# ---------- 健康检查（可选） ----------
RUN apt-get update && apt-get install -y --no-install-recommends curl \
 && rm -rf /var/lib/apt/lists/*
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD curl -fsS http://127.0.0.1:${PORT}/health || exit 1

# ---------- 开放端口 ----------
EXPOSE 8000

# ---------- 启动命令 ----------
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
