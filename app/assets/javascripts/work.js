$(document).ready(function() {
    // Функция обновления изображения и названия
    function updateImageDisplay(data) {
        window.imageCurrentIndex = data.new_image_index;
        $('.image_display h2.up').html(data.name);
        $(".img-center img").attr("src", data.image_url);
        $(".img-center img").attr("alt", data.name);
        $(".img-center img").attr("title", data.name);
        console.log("Updated to image:", data.name, "URL:", data.image_url);
    }

    // Кнопка "Вправо" (следующее изображение)
    $('.img-right-side').on('click', function(e) {
        e.preventDefault();
        var index = window.imageCurrentIndex;
        var themeId = window.selectedThemeId;
        var length = window.themeImagesSize;

        if (isNaN(index) || isNaN(themeId) || isNaN(length) || !themeId) {
            console.log("Сначала выберите тему");
            return;
        }

        $.ajax({
            type: 'GET',
            url: '/api/next_image',
            data: { index: index, theme_id: themeId, length: length },
            dataType: 'json',
            success: updateImageDisplay,
            error: function(xhr, status, error) {
                console.log('Ошибка при загрузке следующего изображения:', error);
            }
        });
    });

    // Кнопка "Влево" (предыдущее изображение)
    $('.img-left-side').on('click', function(e) {
        e.preventDefault();
        var index = window.imageCurrentIndex;
        var themeId = window.selectedThemeId;
        var length = window.themeImagesSize;

        if (isNaN(index) || isNaN(themeId) || isNaN(length) || !themeId) {
            console.log("Сначала выберите тему");
            return;
        }

        $.ajax({
            type: 'GET',
            url: '/api/prev_image',
            data: { index: index, theme_id: themeId, length: length },
            dataType: 'json',
            success: updateImageDisplay,
            error: function(xhr, status, error) {
                console.log('Ошибка при загрузке предыдущего изображения:', error);
            }
        });
    });
});