# omsi2-hof-adder
Powershell scripts for distributing OMSI 2 HOF files to vehicles and installing maps

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

## Installing maps

`install-map.ps1` installs a map from a folder containing the extracted map archive.

```powershell
.\install-map.ps1 -MapSourcePath "C:\Downloads\Paris25_1.0"
```

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `-MapSourcePath` | Yes | Path to the extracted map archive. It must contain `maps\<map name>\global.cfg`, directly or inside one extra subfolder |
| `-OMSI2Path` | No | Path to your OMSI 2 installation. Defaults to the standard Steam location |
| `-Overwrite` | No | Replace existing files that differ from the map's versions |

### Behavior

The script merges all folders from the archive (`maps`, `Sceneryobjects`, `Splines`, `Vehicles`, etc.) into your OMSI 2 folder. Loose files in the archive root, such as PDF manuals, are not copied.

Identical files are skipped, so it is safe to run the script again. If an existing file differs from the map's version, the script keeps yours and lists it in the output.

> [!WARNING]
> `-Overwrite` does not create backups. These folders are shared between all maps, so replacing files may affect other maps.

---

# omsi2-hof-adder (Українська)

Powershell скрипти для розповсюдження HOF файлів поміж автобусами та встановлення мап

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

## Встановлення мап

`install-map.ps1` встановлює мапу з папки з розпакованим архівом.

```powershell
.\install-map.ps1 -MapSourcePath "C:\Downloads\Paris25_1.0"
```

### Параметри

| Параметр | Обов'язковий | Опис |
|----------|--------------|------|
| `-MapSourcePath` | Так | Шлях до розпакованого архіву мапи. У ньому має бути `maps\<назва мапи>\global.cfg`, безпосередньо або всередині однієї додаткової підпапки |
| `-OMSI2Path` | Ні | Шлях до OMSI 2. За замовчуванням — стандартне розташування Steam |
| `-Overwrite` | Ні | Замінити наявні файли, які відрізняються від версій із мапи |

### Принцип роботи

Скрипт зливає всі папки з архіву (`maps`, `Sceneryobjects`, `Splines`, `Vehicles` тощо) з папкою OMSI 2. Окремі файли в корені архіву, як-от PDF-інструкції, не копіюються.

Однакові файли пропускаються, тому скрипт можна безпечно запускати повторно. Якщо наявний файл відрізняється від версії з мапи, скрипт залишає ваш файл і показує його у списку.

> [!WARNING]
> `-Overwrite` не створює резервних копій. Ці папки спільні для всіх мап, тому заміна файлів може вплинути на інші мапи.
