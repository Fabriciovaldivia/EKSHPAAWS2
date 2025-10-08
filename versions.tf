terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "credencialfabri"
}

#Terraform usa las credenciales guardadas en tu máquina, en un archivo llamado ~/.aws/credentials (Linux/Mac) o en C:\Users\<tu_usuario>\.aws\credentials (Windows). Para crear ese perfil, ejecuta en tu terminal:
#aws configure --profile credencialfabri
#Buscará las credenciales en tu perfil credencialfabri.
#Usará la región us-east-1.
#Autenticará las llamadas a AWS sin que pongas tus claves dentro del código (⚠️ lo que es mucho más seguro).