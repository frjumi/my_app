// Логика рабочей области: перелистывание изображений и оценивание звёздами
$(document).ready(function() {
  var $workArea = $('#work-area');
  if (!$workArea.length) {
    return;
  }

  var csrfToken = $('meta[name="csrf-token"]').attr('content');
  if (csrfToken) {
    $.ajaxSetup({
      beforeSend: function(xhr) {
        xhr.setRequestHeader('X-CSRF-Token', csrfToken);
      }
    });
  }

  var placeholderUrl = $workArea.data('placeholder-url');
  var pendingRating = 0;
  var savedRating = 0;
  var userHasRated = false;

  function formatAverage(value) {
    if (value === null || value === undefined || value === '' || Number(value) === 0) {
      return '—';
    }
    return parseFloat(value).toFixed(2);
  }

  // Серая звезда (fa-star-o) по умолчанию, жёлто-оранжевая (fa-star) при выборе/наведении
  function highlightStars(count) {
    $('.star-btn').each(function() {
      var starValue = $(this).data('value');
      var $icon = $(this).find('i');
      if (starValue <= count && count > 0) {
        $icon.removeClass('fa-star-o').addClass('fa-star');
        $(this).addClass('star-active');
      } else {
        $icon.removeClass('fa-star').addClass('fa-star-o');
        $(this).removeClass('star-active');
      }
    });
  }

  function setImageSrc($img, url, fallbackUrl) {
    var fallback = fallbackUrl || placeholderUrl;
    $img.off('error.workImage').on('error.workImage', function() {
      $(this).attr('src', fallback);
    });
    $img.attr('src', url);
  }

  function updateSubmitButton() {
    var $btn = $('#submit-rating');
    if (!pendingRating) {
      $btn.prop('disabled', true).text($workArea.data('select-rating-hint'));
      return;
    }

    $btn.prop('disabled', false);
    if (userHasRated) {
      $btn.text($workArea.data('change-rating'));
    } else {
      $btn.text($workArea.data('submit-rating'));
    }
  }

  function applyRatingState(data) {
    window.currentImageId = data.image_id;
    $('.common_ave_value').text(formatAverage(data.new_average || data.common_ave_value));
    $('.image_values_count').text(data.new_total_values || data.image_values_count || 0);
    if (data.theme_values_count !== undefined) {
      $('.theme_values_count').text(data.theme_values_count);
    }

    savedRating = data.user_value || data.value || 0;
    userHasRated = !!(data.user_valued && savedRating > 0);
    pendingRating = savedRating;

    highlightStars(pendingRating);
    updateSubmitButton();
    $('.rating_message').hide();
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

  function submitRating() {
    if (!window.currentImageId) {
      showRatingError($workArea.data('select-theme-first'));
      return;
    }

    if (!pendingRating) {
      showRatingError($workArea.data('select-rating-hint'));
      return;
    }

    $.ajax({
      type: 'POST',
      url: '/api/rate_image',
      data: { image_id: window.currentImageId, value: pendingRating },
      dataType: 'json',
      success: function(data) {
        if (data.status === 'success') {
          savedRating = data.user_value;
          userHasRated = true;
          pendingRating = savedRating;
          $('.common_ave_value').text(formatAverage(data.new_average));
          $('.image_values_count').text(data.new_total_values);
          if (data.theme_values_count !== undefined) {
            $('.theme_values_count').text(data.theme_values_count);
          }
          highlightStars(savedRating);
          updateSubmitButton();
          showRatingMessage(data.message, false);
        } else {
          showRatingError((data.errors || []).join(', ') || data.error);
        }
      },
      error: function(xhr) {
        var payload = xhr.responseJSON || {};
        var message = (payload.errors || []).join(', ') || payload.error || $workArea.data('rating-error');
        showRatingError(message);
      }
    });
  }

  $('.star-btn').on('click', function() {
    pendingRating = $(this).data('value');
    highlightStars(pendingRating);
    updateSubmitButton();
  });

  $('.star-btn').on('mouseenter', function() {
    highlightStars($(this).data('value'));
  });

  $('.rating-stars').on('mouseleave', function() {
    highlightStars(pendingRating);
  });

  $('#submit-rating').on('click', function() {
    submitRating();
  });

  $('.img-right-side .nav-arrow, .img-right-side').on('click', function(e) {
    e.preventDefault();
    navigateImage('/api/next_image');
  });

  $('.img-left-side .nav-arrow, .img-left-side').on('click', function(e) {
    e.preventDefault();
    navigateImage('/api/prev_image');
  });

  function updateImageDisplay(data) {
    if (data.status !== 'success') {
      showRatingError(data.error || 'Unknown error');
      return;
    }

    window.imageCurrentIndex = data.new_image_index;
    $('.image-title').text(data.name).show();
    $('.welcome-title').hide();
    setImageSrc($('.img-center img'), data.image_url, data.placeholder_url || placeholderUrl);
    $('.img-center img').attr('alt', data.name).attr('title', data.name);
    applyRatingState(data);
  }

  function navigateImage(url) {
    if ($workArea.hasClass('work-idle')) {
      return;
    }

    var index = window.imageCurrentIndex;
    var themeId = window.selectedThemeId;
    var length = window.themeImagesSize;

    if (isNaN(index) || isNaN(themeId) || !themeId || length === 0) {
      showRatingError($workArea.data('select-theme-first'));
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
        showRatingError(payload.error || $workArea.data('navigation-error'));
        if (placeholderUrl) {
          setImageSrc($('.img-center img'), placeholderUrl);
        }
      }
    });
  }

  window.WorkRating = {
    applyRatingState: applyRatingState,
    highlightStars: highlightStars,
    updateSubmitButton: updateSubmitButton,
    resetPending: function() {
      pendingRating = 0;
      savedRating = 0;
      userHasRated = false;
      highlightStars(0);
      updateSubmitButton();
    }
  };
});
