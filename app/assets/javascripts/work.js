$(document).ready(function() {
    // Функция обновления изображения и метаданных
    window.updateImageDisplay = function(data) {
        console.log("Updating image display with data:", data);

        // Обновляем глобальный индекс
        window.imageCurrentIndex = data.new_image_index;

        // Обновляем название изображения
        $('.image_display h2.up').html(data.name);

        // Формируем путь к изображению
        var pathImage = "/assets/pictures/" + data.file;
        console.log("Loading image from path:", pathImage);

        // Обновляем картинку
        $(".img-center img").attr("src", pathImage);
        $(".img-center img").attr("alt", data.name);
        $(".img-center img").attr("title", data.name);

        // Если нужно обновить среднюю оценку и статус оценки пользователя
        if (data.user_valued === 1) {
            $('.image_user_value').html("Ваша оценка: " + data.value);
            $('.common_ave_value').html("Средняя оценка: " + data.common_ave_value);
        } else {
            $('.image_user_value').html("Вы еще не оценили это изображение");
        }
    };

    // Обработчик кнопки "Вправо" (следующее изображение)
    $('.img-right-side').on('click', function(e) {
        e.preventDefault();

        var index = window.imageCurrentIndex;
        var themeId = window.selectedThemeId;
        var length = window.themeImagesSize;

        if (isNaN(index) || isNaN(themeId) || isNaN(length) || themeId === 0) {
            console.log("Данные не загружены, сначала выберите тему");
            return;
        }

        console.log("Next image: index=" + index + ", themeId=" + themeId + ", length=" + length);

        $.ajax({
            type: 'GET',
            url: '/api/next_image',
            data: { index: index, theme_id: themeId, length: length },
            dataType: 'json',
            success: function(data) {
                console.log('Next image success:', data);
                if (data.error) {
                    console.log("API error:", data.error);
                    return;
                }
                window.updateImageDisplay(data);
            },
            error: function(xhr, status, error) {
                console.log('Next image error:', error);
                console.log('Response:', xhr.responseText);
            }
        });
    });

    // Обработчик кнопки "Влево" (предыдущее изображение)
    $('.img-left-side').on('click', function(e) {
        e.preventDefault();

        var index = window.imageCurrentIndex;
        var themeId = window.selectedThemeId;
        var length = window.themeImagesSize;

        if (isNaN(index) || isNaN(themeId) || isNaN(length) || themeId === 0) {
            console.log("Данные не загружены, сначала выберите тему");
            return;
        }

        console.log("Prev image: index=" + index + ", themeId=" + themeId + ", length=" + length);

        $.ajax({
            type: 'GET',
            url: '/api/prev_image',
            data: { index: index, theme_id: themeId, length: length },
            dataType: 'json',
            success: function(data) {
                console.log('Prev image success:', data);
                if (data.error) {
                    console.log("API error:", data.error);
                    return;
                }
                window.updateImageDisplay(data);
            },
            error: function(xhr, status, error) {
                console.log('Prev image error:', error);
                console.log('Response:', xhr.responseText);
            }
        });
    });
});