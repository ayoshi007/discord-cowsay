variable "DISCORD_PUBLIC_TOKEN" {
    description = "Public token to Discord"
    sensitive = true
}

variable "LAYER_ZIP_PATH" {
    description = "Path to Lambda layer zip archive"
    default = "venv/layer"
}
