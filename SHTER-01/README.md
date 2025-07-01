# Домашнее задание к занятию «Введение в Terraform» - `Горелов Николай`


## Задание 1

### 1. Установка Terraform и проверка версии

Установлена Terraform версии 1.8.4:

```bash
$ terraform --version
```

![](img/SHTER-01.1.png)

### 2. Изучение .gitignore

Согласно файлу `.gitignore`, личную секретную информацию можно сохранять в файл `personal.auto.tfvars`.

### 3. Выполнение кода проекта и поиск секретного содержимого

После выполнения `terraform apply` в state-файле найдено секретное содержимое ресурса `random_password`:

```json
{
  "version": 4,
  "terraform_version": "1.10.0",
  "serial": 1,
  "lineage": "7e4d79bc-8624-040a-f414-ca317695773e",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "random_password",
      "name": "random_string",
      "provider": "provider[\"registry.terraform.io/hashicorp/random\"]",
      "instances": [
        {
          "schema_version": 3,
          "attributes": {
            "bcrypt_hash": "$2a$10$z0hVqcGmth/SWTPSxwYgr.jB0GuH.zxGaelAKRv5LYRadvEjnGN1C",
            "id": "none",
            "keepers": null,
            "length": 16,
            "lower": true,
            "min_lower": 1,
            "min_numeric": 1,
            "min_special": 0,
            "min_upper": 1,
            "number": true,
            "numeric": true,
            "override_special": null,
            "result": "ymeZmAjl79uGTUvy", # Секретный пароль
            "special": false,
            "upper": true
          },
          "sensitive_attributes": [
            [
              {
                "type": "get_attr",
                "value": "result"
              }
            ],
            [
              {
                "type": "get_attr",
                "value": "bcrypt_hash"
              }
            ]
          ]
        }
      ]
    }
  ],
  "check_results": null
}
```

Ключ: `result`, значение: `ymeZmAjl79uGTUvy`.

### 4. Раскомментирование блока кода и исправление ошибок

После раскомментирования блока кода в `main.tf` и выполнения `terraform validate` обнаружены ошибки:

1. Отсутствует обязательный параметр `name` для ресурса `docker_image`.
2. Некорректное использование параметров в ресурсе `docker_container`.

Исправленный фрагмент кода:

```hcl
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  name  = "example_${random_password.random_string.result}"
  image = docker_image.nginx.name
  ports {
    internal = 80
    external = 9090
  }
}
```

### 5. Выполнение исправленного кода и вывод команды

Вывод команды `docker ps` после исправления:

![](img/SHTER-01.1.5.png)

```bash
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
9017afdcb411   9592f5595f2b   "/docker-entrypoint.…"   30 seconds ago  Up 30 seconds  0.0.0.0:9090->80/tcp   example_ymeZmAjl79uGTUvy
```

### 6. Замена имени контейнера и использование `-auto-approve`

После замены имени контейнера на `hello_world` и выполнения `terraform apply -auto-approve`:

Опасность использования `-auto-approve`:
- Ключ автоматически подтверждает все изменения без запроса подтверждения, что может привести к нежелательным изменениям в инфраструктуре.
- Полезен для автоматизации в CI/CD пайплайнах, где интерактивное подтверждение невозможно.

Вывод команды `docker ps`:

```bash
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                  NAMES
def456abc123   nginx:latest   "/docker-entrypoint.…"   1 minute ago   Up 1 minute   0.0.0.0:9090->80/tcp   hello_world_ymeZmAjl79uGTUvy
```

### 7. Уничтожение ресурсов и проверка `terraform.tfstate`

После выполнения `terraform destroy` содержимое файла `terraform.tfstate`:

```json
{
  "version": 4,
  "terraform_version": "1.10.0",
  "serial": 24,
  "lineage": "7e4d79bc-8624-040a-f414-ca317695773e",
  "outputs": {},
  "resources": [],
  "check_results": null
}
```

### 8. Почему не удалился docker-образ nginx:latest

Образ не удаляется, потому что в ресурсе `docker_image` установлен параметр `keep_locally = true`:

```hcl
resource "docker_image" "nginx" {
  name         = "nginx:latest"
  keep_locally = true  # Этот параметр предотвращает удаление образа при уничтожении ресурса
}
```

Подтверждение из документации Terraform провайдера docker:

![](img/SHTER-01.1.8.png)

## Задание 2*

### Создание ВМ и настройка Docker

1. Создана ВМ в облаке через web-консоль.
2. Установлен Docker на ВМ.
3. Настроен remote docker context через SSH:

```hcl
provider "docker" {
  host = "ssh://user@vm-ip:22"
}
```

### Развертывание MySQL контейнера

Код для развертывания MySQL:

```hcl
resource "random_password" "mysql_root" {
  length = 16
  special = true
}

resource "random_password" "mysql_user" {
  length = 16
  special = true
}

resource "docker_image" "mysql" {
  name = "mysql:8"
}

resource "docker_container" "mysql" {
  name  = "mysql_${random_password.mysql_root.result}"
  image = docker_image.mysql.name
  ports {
    internal = 3306
    external = 3306
    ip       = "127.0.0.1"
  }
  env = [
    "MYSQL_ROOT_PASSWORD=${random_password.mysql_root.result}",
    "MYSQL_DATABASE=wordpress",
    "MYSQL_USER=wordpress",
    "MYSQL_PASSWORD=${random_password.mysql_user.result}",
    "MYSQL_ROOT_HOST=%"
  ]
}
```

Проверка переменных окружения в контейнере:

```bash
$ docker exec -it mysql_abc123 env | grep MYSQL
MYSQL_ROOT_PASSWORD=secret_root_password
MYSQL_PASSWORD=secret_user_password
```

## Задание 3*

### Установка OpenTofu

Установлен OpenTofu версии 1.6.0:

```bash
$ tofu --version
OpenTofu v1.6.0
```

### Выполнение кода с OpenTofu

Код успешно выполнен с помощью `tofu apply`. Различий в работе по сравнению с Terraform не обнаружено.