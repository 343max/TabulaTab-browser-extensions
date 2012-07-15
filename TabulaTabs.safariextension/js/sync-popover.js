if (typeof(chrome) != 'undefined') {
    document.onTabsSaved = function() {
        $('#progress').text('Synchronization complete').removeClass('inprogress');

        window.setTimeout(function() {
            window.close();
        }, 10000);
    }

    $().ready(function() {
        $('p#options').click(function() {
            chrome.extension.getBackgroundPage().openOptions(false);
            window.close();
        }).blur();

        chrome.extension.getBackgroundPage().forceTabSync();
    });
};
