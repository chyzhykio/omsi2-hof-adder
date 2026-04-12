# omsi2-hof-adder
A Powershell script for distributing OMSI 2 HOF files to vehicles

> Українська версія нижче

## Requirements

- Windows with PowerShell 5.1 or later
- OMSI 2 installed (obviously :) )

## Usage

```powershell
.\distribute-hof.ps1 -HOFSourcePath "C:\MyHOFFiles"
```

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-HOFSourcePath` | Yes | Path to the folder containing your `.hof` files |
| `-OMSI2Path` | No | Path to your OMSI 2 installation. Defaults to the standard Steam location |

## Behavior

The script copies all `.hof` files from the source folder directly into each vehicle's directory under `<OMSI2>\Vehicles\`.

> [!TIP]
> If you got an error "cannot be loaded because running scripts is disabled on this system.", set Execution policy to RemoteSigned -Scope Process
> ```
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
>```

---

# omsi2-hof-adder (Українська)

Powershell скрипт для розповсюдження HOF файлів поміж автобусами

## Вимоги

- Windows із PowerShell 5.1 або новішої версії
- Встановлений OMSI 2 (без цього було б складно :) )

## Використання

```powershell
.\distribute-hof.ps1 -HOFSourcePath "C:\MyHOFFiles"
```

### Параметри

| Параметр | Обов'язковий | Опис |
|----------|--------------|------|
| `-HOFSourcePath` | Так | Шлях до папки з вашими `.hof` файлами |
| `-OMSI2Path` | Ні | Шлях до OMSI 2. За замовчуванням — стандартне розташування Steam |

## Принцип роботи

Скрипт копіює всі `.hof` файли з вихідної папки безпосередньо до директорії кожного автобуса в `<OMSI2>\Vehicles\`.

> [!TIP]
> Якщо у вас висвітлилася помилка "cannot be loaded because running scripts is disabled on this system.", встановіть Execution policy to RemoteSigned -Scope Process
> ```
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
>```
