for service in accounting ad cart currency email flagd-ui fraud-detection frontend frontend-proxy image-provider kafka load-generator opensearch payment postgres product-catalog quote recommendation shipping checkout; do
  aws ecr create-repository \
    --repository-name $service \
    --region us-west-2 && echo "✅ Created: $service" || echo "⚠️ Already exists: $service"
done