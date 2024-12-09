-- Inicializa o gerenciador de scripts
script_bot = {};
script_path = '/meus_scripts/';
script_path_json = script_path .. player:getName() .. '.json';

-- Versão atual do gerenciador
actualVersion = 1.0;

-- Estrutura do gerenciador de scripts
script_manager = {
    actualVersion = 1.0,
    _cache = {
        -- Aqui você adicionará as categorias e seus scripts
        ['Exemplo'] = {
            ['Meu Primeiro Script'] = {
                url = 'C:\Users\warki\OneDrive\Documentos\GitHub\MeuCommunityScripts\scripts\meu_primeiro_script.lua',
                description = 'Scripts Wall Lima.',
                author = 'Wall Lima',
                enabled = false, -- Altere para "true" se quiser habilitar
            },
        },
    },
};

-- Função para criar o diretório de armazenamento se não existir
_G = modules._G;
g_resources = _G.g_resources;

if not g_resources.fileExists(script_path) then
    g_resources.makeDir(script_path);
end

-- Função para carregar scripts do arquivo JSON
script_bot.readFileContents = function()
    if g_resources.fileExists(script_path_json) then
        local content = g_resources.readFileContents(script_path_json);
        local status, result = pcall(json.decode, content);
        if status then
            script_manager = result;
        else
            print("Erro ao carregar JSON:", result);
        end
    else
        script_bot.saveScripts();
    end
end

-- Função para salvar scripts no arquivo JSON
script_bot.saveScripts = function()
    local data = json.encode(script_manager, 4);
    local status, err = pcall(function()
        g_resources.writeFileContents(script_path_json, data);
    end);
    if not status then
        print("Erro ao salvar arquivo:", err);
    end
end

-- Função para carregar e executar script remoto
script_bot.loadRemoteScript = function(url)
    modules.corelib.HTTP.get(url, function(script)
        local status, err = pcall(function()
            assert(loadstring(script))();
        end)
        if not status then
            print("Erro ao carregar o script remoto:", err);
        end
    end)
end

-- Função para inicializar os scripts habilitados
script_bot.initializeScripts = function()
    for category, scripts in pairs(script_manager._cache) do
        for name, script in pairs(scripts) do
            if script.enabled then
                script_bot.loadRemoteScript(script.url);
            end
        end
    end
end

-- Função para exibir os scripts no console
script_bot.listScripts = function()
    for category, scripts in pairs(script_manager._cache) do
        print("Categoria:", category);
        for name, script in pairs(scripts) do
            print("  - Nome:", name);
            print("    URL:", script.url);
            print("    Autor:", script.author);
            print("    Descrição:", script.description);
            print("    Ativado:", script.enabled and "Sim" or "Não");
        end
    end
end

-- Carregar os dados salvos e inicializar scripts habilitados
script_bot.readFileContents();
script_bot.initializeScripts();

script_bot.widget = setupUI([[
MainWindow
  !text: tr('Meu Script Manager')
  size: 300 400

  ScrollablePanel
    id: scriptList
    anchors.fill: parent
    margin: 5
]], g_ui.getRootWidget());
script_bot.widget:hide();

-- Função para atualizar a lista de scripts na interface
script_bot.updateScriptList = function()
    local scriptList = script_bot.widget.scriptList;
    scriptList:destroyChildren();

    for category, scripts in pairs(script_manager._cache) do
        for name, script in pairs(scripts) do
            local label = g_ui.createWidget('Label', scriptList);
            label:setText(name .. (script.enabled and " [Ativado]" or " [Desativado]"));
            label:setTooltip(script.description);

            label.onClick = function()
                script.enabled = not script.enabled;
                script_bot.saveScripts();
                script_bot.updateScriptList();
            end
        end
    end
end

-- Botão para abrir a interface
UI.Button("Gerenciar Scripts", function()
    script_bot.widget:show();
    script_bot.updateScriptList();
end)