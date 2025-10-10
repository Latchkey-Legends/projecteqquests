import os

OUTPUT_FILE = "Spire-API-info.md"
DOCS_ROOT = os.path.dirname(__file__)

INCLUDE_FOLDERS = ["constants", "events", "methods"]
LUA_MODULES_FOLDER = os.path.abspath(os.path.join(DOCS_ROOT, "..", "lua_modules"))
PLUGINS_FOLDER = os.path.abspath(os.path.join(DOCS_ROOT, "..", "plugins"))
DBSCHEMA_FOLDER = os.path.join(DOCS_ROOT, "dbschema")
DBSCHEMA_OUTPUT = os.path.join(DOCS_ROOT, "DBSchema.md")
# Helper to get all files recursively in a folder
def get_all_files(folder):
    all_files = []
    for root, dirs, files in os.walk(folder):
        for file in files:
            all_files.append(os.path.join(root, file))
    return all_files
def build_dbschema_header(path, dbschema_root):
    rel_path = os.path.relpath(path, dbschema_root)
    parts = rel_path.split(os.sep)
    folder = parts[0].capitalize() if len(parts) > 1 else "DBSchema"
    filename = os.path.splitext(parts[-1])[0]
    return f"## {folder}: {filename}\n"
DOCS_ROOT = os.path.dirname(__file__)

INCLUDE_FOLDERS = ["constants", "events", "methods"]
LUA_MODULES_FOLDER = os.path.abspath(os.path.join(DOCS_ROOT, "..", "lua_modules"))
PLUGINS_FOLDER = os.path.abspath(os.path.join(DOCS_ROOT, "..", "plugins"))


# Helper to get all .md files recursively in a folder
def get_md_files(folder):
    md_files = []
    for root, dirs, files in os.walk(folder):
        for file in files:
            if file.endswith(".md"):
                md_files.append(os.path.join(root, file))
    return md_files


# Helper to get all .lua files recursively in lua_modules
def get_lua_files(folder):
    lua_files = []
    for root, dirs, files in os.walk(folder):
        for file in files:
            if file.endswith(".lua"):
                lua_files.append(os.path.join(root, file))
    return lua_files

# Helper to get all .pl files recursively in plugins
def get_pl_files(folder):
    pl_files = []
    for root, dirs, files in os.walk(folder):
        for file in files:
            if file.endswith(".pl"):
                pl_files.append(os.path.join(root, file))
    return pl_files

# Build reference header from path

def build_header(md_path, docs_root):
    rel_path = os.path.relpath(md_path, docs_root)
    parts = rel_path.split(os.sep)
    folder = parts[0].capitalize() if len(parts) > 1 else "Docs"
    filename = os.path.splitext(parts[-1])[0]
    return f"## {folder}: {filename}\n"


def build_lua_header(lua_path, lua_root):
    rel_path = os.path.relpath(lua_path, lua_root)
    parts = rel_path.split(os.sep)
    folder = parts[0].capitalize() if len(parts) > 1 else "LuaModules"
    filename = os.path.splitext(parts[-1])[0]
    return f"## Lua Module: {folder} / {filename}\n"

def build_pl_header(pl_path, pl_root):
    rel_path = os.path.relpath(pl_path, pl_root)
    parts = rel_path.split(os.sep)
    folder = parts[0].capitalize() if len(parts) > 1 else "Plugins"
    filename = os.path.splitext(parts[-1])[0]
    return f"## Perl Plugin: {folder} / {filename}\n"

# Main build function


def build_api_info():
    docs_root = DOCS_ROOT
    output_path = os.path.join(docs_root, OUTPUT_FILE)
    all_md_files = []
    for folder in INCLUDE_FOLDERS:
        folder_path = os.path.join(docs_root, folder)
        if os.path.exists(folder_path):
            all_md_files.extend(get_md_files(folder_path))
    # Get all lua module files
    lua_files = get_lua_files(LUA_MODULES_FOLDER) if os.path.exists(LUA_MODULES_FOLDER) else []
    # Get all perl plugin files
    pl_files = get_pl_files(PLUGINS_FOLDER) if os.path.exists(PLUGINS_FOLDER) else []
    with open(output_path, "w", encoding="utf-8") as out:
        out.write(f"# Spire API Reference\n\n")
        # Write markdown docs
        for md_file in sorted(all_md_files):
            header = build_header(md_file, docs_root)
            out.write(header)
            out.write("\n")
            with open(md_file, "r", encoding="utf-8") as f:
                out.write(f.read())
                out.write("\n\n")
        # Write lua module docs
        for lua_file in sorted(lua_files):
            lua_header = build_lua_header(lua_file, LUA_MODULES_FOLDER)
            out.write(lua_header)
            out.write("\n``lua\n")
            with open(lua_file, "r", encoding="utf-8") as f:
                out.write(f.read())
            out.write("\n``\n\n")
        # Write perl plugin docs
        for pl_file in sorted(pl_files):
            pl_header = build_pl_header(pl_file, PLUGINS_FOLDER)
            out.write(pl_header)
            out.write("\n``perl\n")
            with open(pl_file, "r", encoding="utf-8") as f:
                out.write(f.read())
            out.write("\n``\n\n")
    # Build DBSchema.md from dbschema folder
    if os.path.exists(DBSCHEMA_FOLDER):
        db_files = get_all_files(DBSCHEMA_FOLDER)
        with open(DBSCHEMA_OUTPUT, "w", encoding="utf-8") as dbout:
            dbout.write(f"# Database Schema Reference\n\n")
            for db_file in sorted(db_files):
                db_header = build_dbschema_header(db_file, DBSCHEMA_FOLDER)
                dbout.write(db_header)
                dbout.write("\n```")
                with open(db_file, "r", encoding="utf-8") as f:
                    dbout.write(f.read())
                dbout.write("\n``\n\n")
        print(f"Built {DBSCHEMA_OUTPUT} with {len(db_files)} files.")

if __name__ == "__main__":
    build_api_info()
