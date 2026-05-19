// Логика рабочей области: перелистывание и оценивание
(function() {
  var pendingRating = 0;
  var savedRating = 0;

  function getWorkArea() {
    return $('#work-area');
  }

  function formatAverage(value) {
    if (value === null || value === undefined || value === '' || Number(value) === 0) {
      return '—';
    }
    return parseFloat(value).toFixed(2);
  }

  // Неактивные — серые (fa-star-o), выбранные — жёлто-оранжевые (fa-star)
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
    var $workArea = getWorkArea();
    var fallback = fallbackUrl || $workArea.data('placeholder-url');
    $img.off('error.workImage').on('error.workImage', function() {
      $(this).attr('src', fallback);
    });
    $img.attr('src', url);
  }

  function updateSubmitButton() {
    var $workArea = getWorkArea();
    var $btn = $('#submit-rating');

    if (!pendingRating) {
      $btn.prop('disabled', true).text($workArea.data('select-rating-hint'));
      return;
    }

    $btn.prop('disabled', false).text($workArea.data('submit-rating'));
  }

  function applyRatingState(data) {
    if (data.image_id) {
      window.currentImageId = data.image_id;
    }

    $('.common_ave_value').text(formatAverage(data.new_average || data.common_ave_value));
    $('.image_values_count').text(data.new_total_values || data.image_values_count || 0);

    if (data.theme_values_count !== undefined) {
      $('.theme_values_count').text(data.theme_values_count);
    }

    savedRating = data.user_value || data.value || 0;
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
    var $workArea = getWorkArea();

    if ($workArea.hasClass('work-idle') || !window.currentImageId) {
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

  function updateImageDisplay(data) {
    if (data.status !== 'success') {
      showRatingError(data.error || 'Unknown error');
      return;
    }

    window.imageCurrentIndex = data.new_image_index;
    window.currentImageId = data.image_id;

    $('.image-title').text(data.name).show();
    $('.welcome-title').hide();
    getWorkArea().removeClass('work-idle');

    setImageSrc($('.img-center img'), data.image_url, data.placeholder_url);
    $('.img-center img').attr('alt', data.name).attr('title', data.name);
    applyRatingState(data);
  }

  function navigateImage(url) {
    var $workArea = getWorkArea();

    if ($workArea.hasClass('work-idle')) {
      return;
    }

    var index = parseInt(window.imageCurrentIndex, 10);
    var themeId = parseInt(window.selectedThemeId, 10);
    var length = parseInt(window.themeImagesSize, 10);

    if (isNaN(index) || isNaN(themeId) || themeId <= 0 || isNaN(length) || length <= 0) {
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
      }
    });
  }

  function initWorkPage() {
    var $workArea = getWorkArea();
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

    $workArea.off('click.workNav click.workStar click.workSubmit mouseenter.workStar mouseleave.workStars');

    $workArea.on('click.workNav', '.img-right-side, .img-right-side .nav-arrow', function(e) {
      e.preventDefault();
      e.stopPropagation();
      navigateImage('/api/next_image');
    });

    $workArea.on('click.workNav', '.img-left-side, .img-left-side .nav-arrow', function(e) {
      e.preventDefault();
      e.stopPropagation();
      navigateImage('/api/prev_image');
    });

    $workArea.on('click.workStar', '.star-btn', function() {
      pendingRating = $(this).data('value');
      highlightStars(pendingRating);
      updateSubmitButton();
    });

    $workArea.on('mouseenter.workStar', '.star-btn', function() {
      highlightStars($(this).data('value'));
    });

    $workArea.on('mouseleave.workStars', '.rating-stars', function() {
      highlightStars(pendingRating);
    });

    $workArea.on('click.workSubmit', '#submit-rating', function() {
      submitRating();
    });

    if ($workArea.hasClass('work-idle')) {
      pendingRating = 0;
      savedRating = 0;
      highlightStars(0);
      updateSubmitButton();
    }
  }

  window.WorkNav = {
    setContext: function(index, themeId, imagesSize, imageId) {
      window.imageCurrentIndex = index;
      window.selectedThemeId = themeId;
      window.themeImagesSize = imagesSize;
      window.currentImageId = imageId;
    }
  };

  window.WorkRating = {
    applyRatingState: applyRatingState,
    highlightStars: highlightStars,
    updateSubmitButton: updateSubmitButton,
    resetPending: function() {
      pendingRating = 0;
      savedRating = 0;
      highlightStars(0);
      updateSubmitButton();
    }
  };

  $(document).on('turbolinks:load ready', initWorkPage);
})();
