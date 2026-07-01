// Логика рабочей области: Kaminari-пагинация (по 1 изображению) и оценивание
(function() {
  var pendingRating = 0;
  var savedRating = 0;

  function getWorkArea() {
    return $('#work-area');
  }

  function appLocale() {
    return $('html').attr('lang') || 'ru';
  }

  function apiUrl(path) {
    return '/' + appLocale() + path;
  }

  function formatAverage(value) {
    if (value === null || value === undefined || value === '' || Number(value) === 0) {
      return '—';
    }
    return parseFloat(value).toFixed(2);
  }

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

  function updateAiFactsState(aiFact) {
    var $block = $('.work-ai-facts');
    var $text = $('.ai-fact-text');
    var $btn = $('#load-ai-facts');
    var $workArea = getWorkArea();

    if ($workArea.hasClass('work-idle') || !window.currentImageId) {
      $block.hide();
      $text.hide().text('');
      $btn.hide().prop('disabled', false).text($workArea.data('facts-button'));
      return;
    }

    $block.show();

    if (aiFact) {
      $text.text(aiFact).show();
      $btn.hide();
    } else {
      $text.hide().text('');
      $btn.show().prop('disabled', false).text($workArea.data('facts-button'));
    }
  }

  function loadAiFacts() {
    var $workArea = getWorkArea();
    var $btn = $('#load-ai-facts');

    if ($workArea.hasClass('work-idle') || !window.currentImageId) {
      showRatingError($workArea.data('select-theme-first'));
      return;
    }

    $btn.prop('disabled', true).text($workArea.data('facts-loading'));

    $.ajax({
      type: 'POST',
      url: apiUrl('/api/ai_fact'),
      data: { image_id: window.currentImageId },
      dataType: 'json',
      success: function(data) {
        if (data.status === 'success') {
          updateAiFactsState(data.ai_fact);
        } else {
          showRatingError(data.error || $workArea.data('facts-error'));
          $btn.prop('disabled', false).text($workArea.data('facts-button'));
        }
      },
      error: function(xhr) {
        var payload = xhr.responseJSON || {};
        showRatingError(payload.error || $workArea.data('facts-error'));
        $btn.prop('disabled', false).text($workArea.data('facts-button'));
      }
    });
  }

  function updatePaginationUI(data) {
    var firstPage = data.first_page === true || data.first_page === 'true';
    var lastPage = data.last_page === true || data.last_page === 'true';
    var currentPage = data.current_page || window.currentPage || 1;
    var totalPages = data.total_pages || window.totalPages || 0;

    window.currentPage = currentPage;
    window.totalPages = totalPages;

    $('.img-left-side').toggleClass('nav-disabled', firstPage);
    $('.img-right-side').toggleClass('nav-disabled', lastPage);
    $('.page-current').text(currentPage);
    $('.page-total').text(totalPages);
    $('.image-kaminari-nav').toggle(totalPages > 0);
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
      url: apiUrl('/api/rate_image'),
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

    window.currentImageId = data.image_id;

    $('.image-title').text(data.name).show();
    $('.welcome-title').hide();
    getWorkArea().removeClass('work-idle');

    setImageSrc($('.img-center img'), data.image_url, data.placeholder_url);
    $('.img-center img').attr('alt', data.name).attr('title', data.name);
    applyRatingState(data);
    updatePaginationUI(data);
    updateAiFactsState(data.ai_fact || null);
  }

  function navigateImage(path) {
    var $workArea = getWorkArea();

    if ($workArea.hasClass('work-idle')) {
      return;
    }

    var $side = path.indexOf('next') >= 0 ? $('.img-right-side') : $('.img-left-side');
    if ($side.hasClass('nav-disabled')) {
      return;
    }

    var page = parseInt(window.currentPage, 10);
    var themeId = parseInt(window.selectedThemeId, 10);

    if (isNaN(page) || page < 1 || isNaN(themeId) || themeId <= 0) {
      showRatingError($workArea.data('select-theme-first'));
      return;
    }

    $.ajax({
      type: 'GET',
      url: apiUrl(path),
      data: { page: page, theme_id: themeId },
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

    $workArea.off('click.workNav click.workStar click.workSubmit click.workFacts mouseenter.workStar mouseleave.workStars');

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

    $workArea.on('click.workFacts', '#load-ai-facts', function() {
      loadAiFacts();
    });

    if ($workArea.hasClass('work-idle')) {
      pendingRating = 0;
      savedRating = 0;
      highlightStars(0);
      updateSubmitButton();
      updateAiFactsState(null);
    }
  }

  window.WorkNav = {
    setContext: function(opts) {
      window.currentPage = opts.currentPage || 1;
      window.selectedThemeId = opts.themeId;
      window.totalPages = opts.totalPages || 0;
      window.currentImageId = opts.imageId;
      updatePaginationUI({
        current_page: opts.currentPage,
        total_pages: opts.totalPages,
        first_page: opts.firstPage,
        last_page: opts.lastPage
      });
    }
  };

  window.WorkAiFacts = {
    updateState: updateAiFactsState,
    load: loadAiFacts
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
