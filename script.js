const slides = Array.from(document.querySelectorAll('.slide'));
const nav = document.getElementById('sliderNav');
let activeIndex = 0;
let autoSlide;

const setActiveSlide = (index) => {
  slides.forEach((slide, idx) => {
    slide.classList.toggle('active', idx === index);
  });

  const dots = Array.from(nav.children);
  dots.forEach((dot, idx) => dot.classList.toggle('active', idx === index));
  activeIndex = index;
};

const createDots = () => {
  slides.forEach((slide, index) => {
    const dot = document.createElement('button');
    dot.className = 'slider-dot';
    dot.type = 'button';
    dot.addEventListener('click', () => {
      setActiveSlide(index);
      resetTimer();
    });
    nav.appendChild(dot);
  });
};

const nextSlide = () => {
  setActiveSlide((activeIndex + 1) % slides.length);
};

const resetTimer = () => {
  clearInterval(autoSlide);
  autoSlide = setInterval(nextSlide, 6000);
};

if (slides.length && nav) {
  createDots();
  setActiveSlide(0);
  resetTimer();
}
