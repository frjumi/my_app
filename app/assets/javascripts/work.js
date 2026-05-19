$(document).ready(function() {
  var csrfToken = $('meta[name="csrf-token"]').attr('content');
  if (csrfToken) {
    $.ajaxSetup({
      beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', csrfToken);
      }
    });
  }

  var placeholderUrl = $('#work-area').data('placeholder-url');

  function formatAverage(value) {
    if (value === null || value === undefined || value === 0) {
      return '—';
    }
    return parseFloat(value).toFixed(2);
  }

  function setImageSrc($img, url, fallbackUrl) {
    var fallback = fallbackUrl || placeholderUrl;
    $img.off('error.workImage').on('error.workImage', function() {
      $(this).attr('src', fallback);
    });
    $img.attr('src', url);
  }

  function updateRatingUI(data) {
    window.currentImageId = data.image_id;
    $('.common_ave_value').text(formatAverage(data.common_ave_value));
    $('.rating-star').prop('checked', false);

    if (data.user_valued && data.value) {
      $('.rating-star[value="' + data.value + '"]').prop('checked', true);
    }

    $('.rating_message').hide();
  }

  function updateImageDisplay(data) {
    if (data.status !== 'success') {
      showRatingError(data.error || 'Unknown error');
      return;
    }

    window.imageCurrentIndex = data.new_image_index;
    $('.image_display h2.up').text(data.name);
    setImageSrc($('.img-center img'), data.image_url, data.placeholder_url || placeholderUrl);
    $('.img-center img').attr('alt', data.name).attr('title', data.name);
    updateRatingUI(data);
  }

  function showRatingMessage(message, isError) {
    var $msg = $('.rating_message');
    $msg.removeClass('alert-success alert-danger')
        .addClass(isError ? 'alert-danger' : 'alert-success')
        .text(message)
        .show();
  }

  function showRatingError(message) {
    showRatingMessage(message, true);
  }

  function submitRating(value) {
    if (!window.currentImageId) {
      showRatingError($('#work-area').data('select-theme-first'));
      return;
    }

    $.ajax({
      type: 'POST',
      url: '/api/rate_image',
      data: { image_id: window.currentImageId, value: value },
      dataType: 'json',
      success: function(data) {
        if (data.status === 'success') {
          $('.common_ave_value').text(formatAverage(data.common_ave_value));
          showRatingMessage(data.message, false);
        } else {
          showRatingError((data.errors || []).join(', ') || data.error);
        }
      },
      error: function(xhr) {
        var payload = xhr.responseJSON || {};
        var message = (payload.errors || []).join(', ') || payload.error || $('#work-area').data('rating-error');
        showRatingError(message);
      }
    });
  }

  $('.rating-star').on('change', function() {
    submitRating($(this).val());
  });

  $('.img-right-side').on('click', function(e) {
    e.preventDefault();
    navigateImage('/api/next_image');
  });

  $('.img-left-side').on('click', function(e) {
    e.preventDefault();
    navigateImage('/api/prev_image');
  });

  function navigateImage(url) {
    var index = window.imageCurrentIndex;
    var themeId = window.selectedThemeId;
    var length = window.themeImagesSize;

    if (isNaN(index) || isNaN(themeId) || isNaN(length) || !themeId || length === 0) {
      showRatingError($('#work-area').data('select-theme-first'));
      return;
    }

    $.ajax({
      type: 'GET',
      url: url,
      data: { index: index, theme_id: themeId, length: length },
      dataType: 'json',
      success: updateImageDisplay,
      error: function(xhr) {
        var payload = xhr.responseJSON || {};
        showRatingError(payload.error || $('#work-area').data('navigation-error'));
        if (placeholderUrl) {
          setImageSrc($('.img-center img'), placeholderUrl);
        }
      }
    });
  }
});
