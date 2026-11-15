/* Code-Kurs – die ganze Kursseite: Navigation, gemeinsamer Speicher (Account über db, sonst Browser),
 * Reiter Classics (Lernpfad) und Unser Game, Lektionen, Zwischen-Challenges, Finale, Notenbuch und Spielplatz. */
(function () {
  'use strict';
  const JK = window.JK, C = window.COURSE;
  const { $, $$, esc, md, toast, GRADE_WORD, fmtTime } = JK.util;
  const LESSONS = C.lessons, CHAL = C.challenges, FIN = C.finale || [], TR = C.tracks || { classics: [], game: null };
  const FINALE_GATE = 'l12-spiel'; // Das Finale öffnet sich, wenn das Java-Abschlussprojekt abgegeben ist

  // ------------------------------------------------------------------ Zustand
  const KEY = 'javakurs:kurs';
  const S = { v: 1, lessons: {}, quizzes: {}, tasks: {}, openTask: null, last: null };
  try { const raw = localStorage.getItem(KEY); if (raw) Object.assign(S, JSON.parse(raw)); } catch (e) { /* kein Speicher */ }
  const store = { ref: null, writing: false, dirty: false, mode: 'local', note: 'Fortschritt wird nur in diesem Browser gespeichert.' };
  function persist() {
    try { localStorage.setItem(KEY, JSON.stringify(S)); } catch (e) { /* egal */ }
    if (!store.ref) return;
    if (store.writing) { store.dirty = true; return; }
    store.writing = true;
    store.ref.set(JSON.parse(JSON.stringify(S))).catch(() => {}).finally(() => { store.writing = false; if (store.dirty) { store.dirty = false; persist(); } });
  }
  function merge(remote) {
    const before = JSON.stringify([S.tasks, S.quizzes, S.openTask, S.lessons]);
    S.tasks = Object.assign({}, remote.tasks || {}, S.tasks);
    S.quizzes = Object.assign({}, remote.quizzes || {}, S.quizzes);
    for (const [id, l] of Object.entries(remote.lessons || {})) { const mine = S.lessons[id] || (S.lessons[id] = { t: 0, done: false }); mine.t = Math.max(mine.t || 0, l.t || 0); mine.done = mine.done || !!l.done; }
    if (remote.openTask && !S.tasks[remote.openTask.id]) S.openTask = remote.openTask;
    if (S.openTask && S.tasks[S.openTask.id]) S.openTask = null;
    if (!S.last && remote.last) S.last = remote.last;
    return JSON.stringify([S.tasks, S.quizzes, S.openTask, S.lessons]) !== before;
  }
  async function initStore() {
    if (!window.claude || !window.claude.use) return;
    try {
      const user = await window.claude.use('user');
      const uid = user ? await user.id() : null;
      const db = uid ? await window.claude.use('db') : null;
      if (!db || !uid) return;
      store.ref = db.doc('data/users/' + uid + '/kurs'); store.mode = 'db';
      const timer = setTimeout(() => setNote('Dein Fortschritt kann gerade nicht geladen werden – er wird nachgeholt, sobald die Verbindung steht.'), 10000);
      let first = true;
      store.ref.onSnapshot(snap => {
        if (!snap.metadata.fromCache) clearTimeout(timer);
        if (snap.metadata.hasPendingWrites) return;
        let changed = false;
        if (snap.exists) changed = merge(snap.data());
        if (first) { first = false; persist(); }
        setNote('Fortschritt und Noten werden in deinem Account gespeichert – auf allen Geräten gleich.');
        if (changed) { try { localStorage.setItem(KEY, JSON.stringify(S)); } catch (e) { /* egal */ } refresh(); }
      }, () => { clearTimeout(timer); setNote('Fortschritt wird nur in diesem Browser gespeichert.'); });
    } catch (e) { /* lokal weiter */ }
  }
  function setNote(t) { store.note = t; $$('.store-note').forEach(el => (el.textContent = t)); }

  const ctx = {
    state: S, persist, count: LESSONS.length,
    ls: id => S.lessons[id] || (S.lessons[id] = { t: 0, done: false }),
    navigate: h => { if (location.hash === h) route(); else location.hash = h; },
    onChange: () => renderNav(),
  };

  // ------------------------------------------------------------------ Hilfen
  const allTasks = () => LESSONS.flatMap(L => JK.buildTimeline(L).steps.filter(s => s.task).map(s => ({ task: s.task, lesson: L })));
  const subOf = id => S.tasks[id] && S.tasks[id].result ? S.tasks[id] : null;
  const avgOf = ids => { const g = ids.map(subOf).filter(Boolean).map(s => s.result.note); return g.length ? g.reduce((a, b) => a + b, 0) / g.length : null; };
  const finUnlocked = i => i === 0 ? !!subOf(FINALE_GATE) : !!subOf(FIN[i - 1].id);
  const chalAfter = nr => CHAL.filter(c => c.after === nr);
  const allIds = () => allTasks().map(x => x.task.id).concat(CHAL.map(c => c.id), FIN.map(f => f.id));
  const fmtAvg = a => a == null ? '–' : a.toFixed(1).replace('.', ',');
  function lessonProgress(L) {
    const { TOTAL } = JK.buildTimeline(L), ls = S.lessons[L.id];
    if (!ls) return 0;
    return ls.done ? 1 : Math.min(1, (ls.t || 0) / TOTAL);
  }

  // ------------------------------------------------------------------ Navigation
  const nav = $('#nav'), view = $('#view'), banner = $('#lockbar');
  function renderNav() {
    const h = location.hash || '#start';
    const avg = avgOf(allIds());
    const isLesson = /^#lektion-/.test(h);
    const finDone = FIN.filter(f => subOf(f.id)).length;
    nav.innerHTML = `
      <a class="brand" href="#start">☕ Code-Kurs</a>
      <div class="navlinks" role="list">
        <a role="listitem" href="#start" class="tab ${h === '#start' || isLesson ? 'on' : ''}">Classics</a>
        <a role="listitem" href="#game" class="tab game ${h === '#game' ? 'on' : ''}">Unser Game</a>
        <span class="navsep" aria-hidden="true"></span>
        <a role="listitem" href="#challenges" class="${/^#challenge/.test(h) ? 'on' : ''}">Challenges</a>
        <a role="listitem" href="#finale" class="${/^#finale/.test(h) ? 'on' : ''}">Finale <b class="avgchip">${finDone}/${FIN.length}</b></a>
        <a role="listitem" href="#noten" class="${h === '#noten' ? 'on' : ''}">Notenbuch <b class="avgchip">${fmtAvg(avg)}</b></a>
        <a role="listitem" href="#spielplatz" class="${h === '#spielplatz' ? 'on' : ''}">Spielplatz</a>
      </div>`;
    const ot = S.openTask;
    banner.hidden = !ot || h === '#lektion-' + (ot && ot.nr);
    if (ot) banner.innerHTML = `<span>🔒 <b>Aufgabe offen:</b> „${esc(ot.title)}“ in Lektion ${ot.nr}. Alle Videos sind gesperrt, bis du abgibst.</span><a class="btn primary" href="#lektion-${ot.nr}">Zur Aufgabe</a>`;
  }

  // ------------------------------------------------------------------ Ansichten
  let active = null;
  function route() {
    if (active && active.destroy) active.destroy();
    active = null;
    const h = (location.hash || '#start').slice(1);
    let m;
    view.innerHTML = '';
    window.scrollTo(0, 0);
    if ((m = /^lektion-(\d+)$/.exec(h)) && LESSONS[Number(m[1]) - 1]) {
      const i = Number(m[1]) - 1, L = LESSONS[i];
      const after = chalAfter(L.nr);
      const last = i === LESSONS.length - 1;
      active = JK.mountLesson(view, L, Object.assign({}, ctx, {
        prevHash: i > 0 ? '#lektion-' + i : null,
        nextHash: last ? '#finale' : '#lektion-' + (i + 2),
        nextLabel: last ? 'Zum Java-Finale' : 'Lektion ' + (i + 2),
        endExtra: after.length ? `<a class="btn" href="#challenge-${after[0].id}">★ ${after.length} Zwischen-Challenge${after.length > 1 ? 's' : ''}</a>` : '',
      }));
      persist();
    } else if (h === 'noten') active = viewGrades();
    else if (h === 'challenges') active = viewChallenges();
    else if ((m = /^challenge-(c\d+)$/.exec(h)) && CHAL.find(c => c.id === m[1])) active = viewChallenge(CHAL.find(c => c.id === m[1]));
    else if (h === 'finale') active = viewFinale();
    else if ((m = /^finale-(\d+)$/.exec(h)) && FIN[Number(m[1]) - 1]) active = viewFinaleTask(Number(m[1]) - 1);
    else if (h === 'game') active = viewGame();
    else if (h === 'spielplatz') active = viewPlayground();
    else active = viewHome();
    renderNav();
  }
  function refresh() { renderNav(); if (active && active.refresh) active.refresh(); else if (!active || !active.player) route(); }

  // Startseite = Reiter „Classics“
  const gradeTag = (id, title) => { const s = subOf(id); return `<span class="tag ${s ? 'g' + s.result.note : ''}">${esc(title)}: ${s ? s.result.note : 'offen'}</span>`; };
  function lessonCard(L) {
    const p = lessonProgress(L), ts = JK.buildTimeline(L).steps.filter(s => s.task).map(s => s.task);
    return `<a class="lesson" href="#lektion-${L.nr}"><div class="num ${p >= 1 ? 'ok' : ''}">${p >= 1 ? '✓' : L.nr}</div>
      <div><h3>${md(L.title)}</h3><p>${md(L.sub)}</p>
        <div class="bar" aria-label="Fortschritt ${Math.round(p * 100)} %"><i style="width:${Math.round(p * 100)}%"></i></div>
        <div class="tags">${ts.map(t => gradeTag(t.id, t.title)).join('')}</div></div>
      <span class="go">${p >= 1 ? 'Wiederholen' : p > 0 ? 'Weiter' : 'Starten'} →</span></a>`;
  }
  function checkpointCard(nr, list) {
    const done = list.filter(c => subOf(c.id)).length;
    return `<div class="checkpoint"><div class="cp-head"><span class="cp-kick">★ Zwischen-Challenges nach Lektion ${nr}</span><span class="muted small">${done}/${list.length} gelöst · freiwillig, aber benotet</span></div>
      <div class="cp-list">${list.map(c => { const s = subOf(c.id); return `<a class="cp-item ${s ? 'g' + s.result.note : ''}" href="#challenge-${c.id}"><b>${md(c.title)}</b><span>${esc(c.level)}${s ? ' · Note ' + s.result.note : ''}</span></a>`; }).join('')}</div></div>`;
  }
  function finaleCard() {
    const done = FIN.filter(f => subOf(f.id)).length, open = finUnlocked(0);
    return `<a class="lesson finale-card ${open ? '' : 'locked'}" href="#finale"><div class="num">${open ? done : '🔒'}</div>
      <div><h3>Java-Finale: 20 Challenges</h3><p>${open ? `Nur nacheinander lösbar – jede öffnet die nächste. ${done}/20 geschafft.` : 'Öffnet sich, sobald du das Abschlussprojekt (Lektion 12, Teil 2) abgegeben hast.'}</p>
      <div class="bar"><i style="width:${done * 5}%"></i></div></div><span class="go">${open ? 'Los →' : 'gesperrt'}</span></a>`;
  }
  function viewHome() {
    const tasks = allTasks();
    const doneT = tasks.filter(x => subOf(x.task.id)).length, doneC = CHAL.concat(FIN).filter(c => subOf(c.id)).length;
    const avg = avgOf(allIds());
    const next = LESSONS.find(L => lessonProgress(L) < 1) || LESSONS[LESSONS.length - 1];
    const nextLs = S.lessons[next.id];
    let path = '';
    for (const L of LESSONS) { path += lessonCard(L); const cs = chalAfter(L.nr); if (cs.length) path += checkpointCard(L.nr, cs); }
    path += finaleCard();
    view.innerHTML = `
      <header class="hero home">
        <div>
          <div class="kick">Classics · Grundlagen fürs Programmieren</div>
          <h1>Programmieren lernen – vom ersten Befehl zum eigenen Spiel</h1>
          <p class="lead">Animierte Lektionen ohne Stimme, Code direkt im Browser und echte Aufgaben mit Noten von 1 bis 5. Ist eine Aufgabe offen, sind alle Videos gesperrt, bis du abgibst.</p>
          <div class="row"><a class="btn primary" href="#lektion-${next.nr}">${nextLs && nextLs.t > 1 && lessonProgress(next) < 1 ? `Weitermachen: Lektion ${next.nr} (bei ${fmtTime(nextLs.t)})` : `Starten: Lektion ${next.nr}`} →</a><a class="btn ghost" href="#game">Zum Game-Reiter</a></div>
        </div>
        <div class="stats">
          <div class="stat"><b>${LESSONS.filter(L => lessonProgress(L) >= 1).length}/${LESSONS.length}</b><span>Java-Lektionen fertig</span></div>
          <div class="stat"><b>${doneT}/${tasks.length}</b><span>Aufgaben abgegeben</span></div>
          <div class="stat"><b>${doneC}/${CHAL.length + FIN.length}</b><span>Challenges gelöst</span></div>
          <div class="stat accent"><b>${fmtAvg(avg)}</b><span>Notenschnitt</span></div>
        </div>
      </header>
      <section class="goal">
        <h2>Das Ziel</h2>
        <p>${md(C.goal)}</p>
        <div class="goalgrid">${C.canDo.map(x => `<div class="gcard"><b>${esc(x.h)}</b><span>${md(x.p)}</span></div>`).join('')}</div>
      </section>
      <section class="path"><div class="sec-head"><span class="badge java">Java</span><h2>Java: 12 Lektionen</h2></div>
        <p class="muted sec-sub">Hier lernst du das Programmieren an sich. Zwischen den Lektionen warten Challenges, die so nie im Video vorkamen – und ganz am Ende das Finale mit 20 Challenges.</p>
        ${path}
      </section>
      ${TR.classics.map(t => `<section class="path"><div class="sec-head"><span class="badge ${t.id}">${esc(t.badge)}</span><h2>${esc(t.title)}</h2><span class="soonchip">kommt als Nächstes</span></div>
        <p class="muted sec-sub">${md(t.sub)}</p>
        <ol class="plan">${t.plan.map((p, i) => `<li><span class="pnum">${i + 1}</span><div><b>${esc(p.title)}</b><span>${esc(p.what)}</span></div></li>`).join('')}</ol></section>`).join('')}
      <section class="how"><h2>So läuft eine Lektion</h2>
        <ol>
          <li><span class="step">Schritt 1</span><b>Video ansehen</b><span>Code tippt sich selbst, Erklärtexte, Schaubilder. Pausieren und Tempo wählen geht jederzeit.</span></li>
          <li><span class="step">Schritt 2</span><b>Kurz-Checks</b><span>Zwischendurch kleine Quizfragen – nicht benotet, nur zum Merken.</span></li>
          <li><span class="step">Schritt 3</span><b>Aufgabe lösen</b><span>Alle Videos sperren sich. Du programmierst, testest mit „Ausführen“ und gibst ab.</span></li>
          <li><span class="step">Schritt 4</span><b>Note bekommen</b><span>Claude bewertet nach österreichischem System (1–5) mit Lob und Tipps.</span></li>
        </ol>
        <p class="muted small">Notengrenzen: ab 90 Punkten 1 · ab 78 → 2 · ab 64 → 3 · ab 50 → 4 · darunter 5. <span class="store-note">${esc(store.note)}</span></p>
      </section>`;
    return {};
  }

  // Reiter „Unser Game“
  function viewGame() {
    const G = TR.game;
    view.innerHTML = `
      <header class="hero game-hero">
        <div>
          <div class="kick">Unser Game · Endprojekt</div>
          <h1>${esc(G.title)}</h1>
          <p class="lead">${md(G.sub)}</p>
        </div>
        <canvas id="gdemo" class="gdemo" width="640" height="240" aria-label="Vorschau: zwei Figuren rennen durch ein Level"></canvas>
      </header>
      <section class="goal"><h2>Was dein Spiel können wird</h2>
        <div class="goalgrid three">${G.features.map(f => `<div class="gcard"><span>${md(f)}</span></div>`).join('')}</div></section>
      <section class="path"><div class="sec-head"><h2>Dafür brauchst du</h2></div>
        <div class="tags big">${G.needs.map((n, i) => `<span class="tag ${i === 0 && subOf(FINALE_GATE) ? 'g1' : ''}">${esc(n)}</span>`).join('')}</div>
        <p class="muted sec-sub">Die Game-Lektionen bauen auf den Classics auf. Java hast du als Erstes – JavaScript, HTML & CSS und Node.js folgen im Classics-Reiter.</p></section>
      <section class="path"><div class="sec-head"><span class="badge game">Game</span><h2>Lernpfad zum Spiel</h2><span class="soonchip">in Arbeit</span></div>
        <ol class="plan">${G.plan.map((p, i) => `<li><span class="pnum">${i + 1}</span><div><b>${esc(p.title)}</b><span>${esc(p.what)}</span></div><span class="lang">${esc(p.langs)}</span></li>`).join('')}</ol></section>`;
    const stop = startDemo($('#gdemo'));
    return { destroy: stop };
  }
  // Kleine Vorschau: zwei Figuren laufen und springen über ein Kachel-Level (rein dekorativ)
  function startDemo(cv) {
    const g = cv.getContext('2d'), T = 24;
    const lvl = ['..........................................', '..........................................', '.............ooo..........................', '...........#####.......ooo................', '.....o.................###.......o..o.....', '...####.........##...........###########..', '##########..######..#####..##############Z', '##########..######..#####..###############'];
    const W = lvl[0].length * T, css = getComputedStyle(document.documentElement);
    const col = n => css.getPropertyValue(n).trim() || '#888';
    const P = [{ x: 0, y: 4 * T, vy: 0, c: '--accent', sp: 2.2 }, { x: -40, y: 4 * T, vy: 0, c: '--blue', sp: 2.0 }];
    const solid = (x, y) => { const r = lvl[Math.floor(y / T)]; return r && r[Math.floor(x / T)] === '#'; };
    let raf, cam = 0, run = true;
    const reduce = window.matchMedia && matchMedia('(prefers-reduced-motion: reduce)').matches;
    function step() {
      for (const p of P) {
        p.x += p.sp; p.vy += 0.5; p.y += p.vy;
        if (solid(p.x + 9, p.y + 20)) { p.y = Math.floor((p.y + 20) / T) * T - 20; p.vy = 0; const ahead = solid(p.x + 30, p.y + 10) || !solid(p.x + 34, p.y + 26); if (ahead) p.vy = -9; }
        if (p.x > W || p.y > 400) { p.x = -20; p.y = 4 * T; p.vy = 0; }
      }
      cam += ((P[0].x - 200) - cam) * 0.08; cam = Math.max(0, Math.min(W - cv.width, cam));
    }
    function draw() {
      g.fillStyle = col('--surface-2'); g.fillRect(0, 0, cv.width, cv.height);
      g.save(); g.translate(-Math.round(cam), 0);
      lvl.forEach((r, y) => [...r].forEach((c, x) => {
        if (c === '#') { g.fillStyle = col('--line'); g.fillRect(x * T, y * T, T, T); g.fillStyle = col('--good'); if (!lvl[y - 1] || lvl[y - 1][x] !== '#') g.fillRect(x * T, y * T, T, 5); }
        if (c === 'o') { g.fillStyle = col('--accent'); g.beginPath(); g.arc(x * T + 12, y * T + 12, 5, 0, 7); g.fill(); }
        if (c === 'Z') { g.fillStyle = col('--fg'); g.fillRect(x * T + 10, y * T - 30, 3, 54); g.fillStyle = col('--bad'); g.fillRect(x * T + 13, y * T - 30, 14, 10); }
      }));
      for (const p of P) { g.fillStyle = col(p.c); g.fillRect(p.x, p.y, 18, 20); g.fillStyle = col('--bg'); g.fillRect(p.x + 11, p.y + 5, 4, 4); }
      g.restore();
    }
    function loop() { if (!run) return; step(); draw(); raf = requestAnimationFrame(loop); }
    if (reduce) { for (let i = 0; i < 120; i++) step(); draw(); } else loop();
    return () => { run = false; cancelAnimationFrame(raf); };
  }

  // Notenbuch
  function viewGrades() {
    const locked = !!S.openTask;
    const groups = [
      { h: 'Java-Lektionen', rows: allTasks().map(x => ({ id: x.task.id, task: x.task, where: `Lektion ${x.lesson.nr}`, href: '#lektion-' + x.lesson.nr })) },
      { h: 'Zwischen-Challenges', rows: CHAL.map(c => ({ id: c.id, task: c, where: `Challenge nach Lektion ${c.after}`, href: '#challenge-' + c.id })) },
      { h: 'Java-Finale', rows: FIN.map((f, i) => ({ id: f.id, task: f, where: `Finale ${i + 1}/20${finUnlocked(i) ? '' : ' · gesperrt'}`, href: '#finale-' + (i + 1) })) },
    ];
    const all = groups.flatMap(g => g.rows);
    const row = r => {
      const s = subOf(r.id);
      return `<details class="grow-row ${s ? 'g' + s.result.note : 'open'}" ${s ? '' : 'data-empty'}><summary><span class="gr-num">${s ? s.result.note : '–'}</span><span class="gtitle"><b>${md(r.task.title)}</b><span class="muted">${r.where}${s ? ' · ' + GRADE_WORD[s.result.note] + ' · ' + s.result.punkte + ' Punkte · ' + new Date(s.at).toLocaleDateString('de-AT') : ' · noch nicht abgegeben'}</span></span><a class="btn ghost small" href="${r.href}">${s ? 'Ansehen' : 'Zur Aufgabe'}</a></summary>
        ${s ? `<div class="gdetail">${JK.resultHTML(r.task, s, { hideSolution: locked })}${locked ? '' : `<h4>Deine Abgabe</h4><pre class="vcode">${JK.util.hlJava(s.code)}</pre>`}</div>` : ''}</details>`;
    };
    view.innerHTML = `
      <header class="lhead"><h1>Notenbuch</h1><p class="lead">Alle Abgaben aus Lektionen, Challenges und Finale an einem Ort. <span class="store-note">${esc(store.note)}</span></p></header>
      <div class="stats wide">
        <div class="stat accent"><b>${fmtAvg(avgOf(all.map(r => r.id)))}</b><span>Gesamtschnitt</span></div>
        <div class="stat"><b>${fmtAvg(avgOf(groups[0].rows.map(r => r.id)))}</b><span>Schnitt Lektionen</span></div>
        <div class="stat"><b>${fmtAvg(avgOf(groups[1].rows.concat(groups[2].rows).map(r => r.id)))}</b><span>Schnitt Challenges</span></div>
        <div class="stat"><b>${all.filter(r => subOf(r.id)).length}/${all.length}</b><span>abgegeben</span></div>
      </div>
      ${groups.map(g => `<section class="gbook"><h2 class="gb-h">${g.h} <span class="muted small">${g.rows.filter(r => subOf(r.id)).length}/${g.rows.length} · Schnitt ${fmtAvg(avgOf(g.rows.map(r => r.id)))}</span></h2>${g.rows.map(row).join('')}</section>`).join('')}`;
    $$('details[data-empty] summary', view).forEach(sm => sm.addEventListener('click', e => { if (!e.target.closest('a')) e.preventDefault(); }));
    return { refresh: () => route() };
  }

  // Challenges (zwischen den Lektionen)
  const chalCard = (c, href, extra = '') => { const s = subOf(c.id); return `<a class="chal-card ${extra}" href="${href}"><div class="chal-top"><span class="lvl">${esc(c.level)}</span>${s ? `<span class="gpill g${s.result.note}">Note ${s.result.note}</span>` : ''}</div><h3>${md(c.title)}</h3><p>${md(c.teaser)}</p><div class="tags">${c.uses.map(u => `<span class="tag">${esc(u)}</span>`).join('')}</div></a>`; };
  function viewChallenges() {
    const afters = [...new Set(CHAL.map(c => c.after))];
    view.innerHTML = `
      <header class="lhead"><div class="crumbs"><span>Zwischen-Challenges</span></div><h1>Kannst du’s auch anders?</h1>
        <p class="lead">Diese Aufgaben kamen so in keinem Video vor. Du hast aber alle Werkzeuge dafür – du musst sie nur neu kombinieren. Jede Gruppe passt zu dem, was du bis zur genannten Lektion gelernt hast.</p></header>
      ${afters.map(a => `<section class="chal-group"><h2>Nach Lektion ${a}: ${esc((LESSONS[a - 1] || {}).title || '')}</h2><div class="chal-list">${chalAfter(a).map(c => chalCard(c, '#challenge-' + c.id)).join('')}</div></section>`).join('')}
      <a class="lesson finale-card ${finUnlocked(0) ? '' : 'locked'}" href="#finale"><div class="num">★</div><div><h3>Und ganz am Ende: das Java-Finale</h3><p>20 Challenges, die nur nacheinander freigeschaltet werden.</p></div><span class="go">Zum Finale →</span></a>`;
    return { refresh: () => route() };
  }
  function viewChallenge(c) {
    const i = CHAL.indexOf(c), prev = CHAL[i - 1], next = CHAL[i + 1];
    view.innerHTML = `<div class="crumbs"><a href="#challenges">← Alle Challenges</a><span>Nach Lektion ${c.after} · Challenge ${i + 1} von ${CHAL.length}</span></div><section id="task" class="task"></section>
      <nav class="lnav">${prev ? `<a class="btn ghost" href="#challenge-${prev.id}">← ${esc(prev.title)}</a>` : '<span></span>'}${next ? `<a class="btn ghost" href="#challenge-${next.id}">${esc(next.title)} →</a>` : '<a class="btn ghost" href="#finale">Zum Finale →</a>'}</nav>`;
    const panel = JK.taskPanel($('#task', view), c, ctx, {
      kicker: `Zwischen-Challenge nach Lektion ${c.after} · ${c.level}`,
      note: 'Kein Video, keine Sperre: Hier zeigst du, dass du das Gelernte neu kombinieren kannst. Auch diese Aufgabe wird benotet und landet im Notenbuch.',
      where: `Transfer-Challenge nach Lektion ${c.after} (Aufgabe so nie gezeigt, nur mit Mitteln aus Lektion 1–${c.after} lösbar)`,
      continueLabel: next ? 'Nächste Challenge →' : 'Zum Finale →',
      onSubmitted: () => renderNav(),
      onContinue: () => ctx.navigate(next ? '#challenge-' + next.id : '#finale'),
    });
    return { destroy: () => panel.destroy(), refresh: () => {} };
  }

  // Finale: 20 Challenges, nur nacheinander
  function viewFinale() {
    const done = FIN.filter(f => subOf(f.id)).length;
    view.innerHTML = `
      <header class="lhead"><div class="crumbs"><span>Java-Finale</span></div><h1>Das Finale: 20 Challenges</h1>
        <p class="lead">Alles gemischt, Schwierigkeit steigt. Jede Challenge öffnet sich erst, wenn du die vorige abgegeben hast – die Note ist dabei egal. ${finUnlocked(0) ? `Du hast ${done} von 20 geschafft.` : '<b>Das Finale öffnet sich, sobald du das Abschlussprojekt in Lektion 12 (Teil 2) abgegeben hast.</b>'}</p>
        <div class="bar wide"><i style="width:${done * 5}%"></i></div></header>
      <ol class="fin-list">${FIN.map((f, i) => { const s = subOf(f.id), open = finUnlocked(i); return `<li>${open ? `<a class="fin-item ${s ? 'done g' + s.result.note : 'cur'}" href="#finale-${i + 1}">` : '<div class="fin-item locked" aria-disabled="true">'}<span class="fnum">${s ? s.result.note : open ? i + 1 : '🔒'}</span><span class="ftxt"><b>${open ? md(f.title) : 'Finale ' + (i + 1)}</b><span>${open ? esc(f.level) : 'gesperrt – erst die vorige Challenge abgeben'}</span></span>${open ? '</a>' : '</div>'}</li>`; }).join('')}</ol>`;
    return { refresh: () => route() };
  }
  function viewFinaleTask(i) {
    const f = FIN[i];
    if (!finUnlocked(i)) {
      view.innerHTML = `<div class="crumbs"><a href="#finale">← Finale</a><span>Finale ${i + 1}/20</span></div>
        <section class="card lockcard"><h2>🔒 Noch gesperrt</h2><p>${i === 0 ? 'Das Finale beginnt nach dem Java-Abschlussprojekt. Gib zuerst Lektion 12, Teil 2 ab.' : `Gib zuerst <a href="#finale-${i}">Finale ${i}: ${esc(FIN[i - 1].title)}</a> ab.`}</p>
        <a class="btn primary" href="${i === 0 ? '#lektion-12' : '#finale-' + i}">${i === 0 ? 'Zu Lektion 12' : 'Zur vorigen Challenge'} →</a></section>`;
      return { refresh: () => route() };
    }
    const next = FIN[i + 1];
    view.innerHTML = `<div class="crumbs"><a href="#finale">← Finale-Übersicht</a><span>Finale ${i + 1} von 20</span></div><section id="task" class="task"></section>
      <nav class="lnav">${i > 0 ? `<a class="btn ghost" href="#finale-${i}">← ${esc(FIN[i - 1].title)}</a>` : '<span></span>'}<a class="btn ghost" href="#finale">Übersicht</a></nav>`;
    const panel = JK.taskPanel($('#task', view), f, ctx, {
      kicker: `Java-Finale ${i + 1}/20 · ${f.level.split(' ')[0]}`,
      note: next ? 'Gibst du diese Challenge ab, öffnet sich die nächste. Benotet wird wie immer von 1 bis 5.' : 'Die letzte Challenge des Java-Finales – der Endgegner!',
      where: `Java-Finale, Challenge ${i + 1} von 20 (nach allen 12 Java-Lektionen, alles darf verwendet werden)`,
      continueLabel: next ? `Weiter zu Finale ${i + 2} →` : 'Zum Notenbuch →',
      onSubmitted: () => renderNav(),
      onContinue: () => ctx.navigate(next ? '#finale-' + (i + 2) : '#noten'),
    });
    return { destroy: () => panel.destroy(), refresh: () => {} };
  }

  // Spielplatz
  function viewPlayground() {
    view.innerHTML = `<header class="lhead"><h1>Spielplatz</h1><p class="lead">Hier kannst du jederzeit Java ausprobieren – auch während eine Aufgabe offen ist. Dein Code bleibt in diesem Browser gespeichert.</p></header>
      <section class="card playground"><div id="pg-ed"></div><div class="task-btns"><button id="pg-run" class="btn">▶ Ausführen</button><button id="pg-stop" class="btn ghost" disabled>■ Stopp</button></div>
      <div class="task-con"><div class="pane-head">Konsole</div><div id="pg-con" class="con-live" role="log"><div class="cl"><span class="k-meta">Drück ▶ Ausführen.</span></div></div></div></section>`;
    let saved = C.playground;
    try { saved = localStorage.getItem('javakurs:playground') || saved; } catch (e) { /* egal */ }
    const ed = JK.makeEditor($('#pg-ed'), saved, v => { try { localStorage.setItem('javakurs:playground', v); } catch (e) { /* egal */ } });
    const runner = JK.makeRunner($('#pg-con'), () => ed.get(), { onState: on => { $('#pg-run').disabled = on; $('#pg-stop').disabled = !on; } });
    $('#pg-run').onclick = () => runner.start();
    $('#pg-stop').onclick = () => runner.stop();
    return { destroy: () => runner.stop() };
  }

  window.addEventListener('hashchange', route);
  route();
  initStore();
  JK.course = { S, route, persist };
})();
