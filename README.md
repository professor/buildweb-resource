{
    "source": {
        "product": "kscom_release",
        "version_regex": ""v1.15",
        "private_key": "..."
    },
    "version": { "version": "v1.15.3+vmware.1" }
}

# Run tests
```bash
docker build .
```

# Publish
```bash
docker login --username
docker image build --tag=toddsedano/buildweb-resource:0.0.2 .
docker push toddsedano/buildweb-resource:0.0.2
```

# Testing locally
```bash
cat spec/fixtures/check.json | docker run toddsedano/buildweb-resource:0.0.2 /opt/resource/check
```
